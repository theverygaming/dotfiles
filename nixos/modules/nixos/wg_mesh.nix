{
  config,
  lib,
  flakeInputs,
  ...
}:

let
  cfg = config.custom.wg_mesh;
in
{
  options.custom.wg_mesh = with lib; {
    enable = mkEnableOption "Enables the WireGuard mesh";
    config = mkOption {
      type = types.submodule {
        options = {
          meshv4NetworkAddress = mkOption {
            type = types.str;
            description = "IPv4 network address including prefix length (e.g. 1.2.3.0/24) seen by the end user";
          };
          getPeerIntIp = mkOption {
            type = types.anything;
            # TODO: description is outdated. Missing withSubnetMask info and offset
            description = ''
              Returns an IP address string in CIDR notation based on the given peerID, netOffset, offset and the isInterfaceAddr, isNetworkAddress and withSubnetMask flags
              - If isInterfaceAddr is false, it returns either an IPv4 (/24) or IPv6 (/128) address assigned to the peer
              - If isInterfaceAddr is true, it returns the same address as above, but with the full internal network
                subnet (IPv4 or IPv6) assigned to the peer's WireGuard interface
              This address is used internally for configuring the WireGuard interface on the specified peer
            '';
          };
          getV6LinkLocal = mkOption {
            type = types.anything;
            description = ''
              Returns an IPv6 link-local address string in CIDR notation given peerID (it should be unique to the peer)
            '';
          };
          hosts = mkOption {
            type = types.attrsOf (
              types.submodule (
                { ... }:
                {
                  options = {
                    port = mkOption {
                      type = types.port;
                      description = "WireGuard UDP port used on this host";
                    };

                    peerId = mkOption {
                      type = types.anything;
                      description = ''
                        Something that uniquely identifies this peer (used by getPeerIntIp)
                      '';
                    };

                    publicKey = mkOption {
                      type = types.str;
                      description = ''
                        WireGuard public key for this host
                      '';
                    };

                    meshNodeAddress = mkOption {
                      type = types.str;
                      description = "IPv4 network address in the mesh for this node";
                    };

                    networks = mkOption {
                      type = types.attrsOf (
                        types.submodule {
                          options = {
                            ips = mkOption {
                              type = types.listOf types.str;
                              description = "List of IPs for the network";
                            };
                          };
                        }
                      );
                      description = "Networks this host is in directly";
                    };

                    reachableNetworks = mkOption {
                      type = types.listOf types.str;
                      description = "List of network names this host can reach";
                    };
                  };
                }
              )
            );
            description = "Configuration for all hosts";
          };
        };
      };
      description = ''
        Full WireGuard mesh configuration
      '';
    };

    interface = mkOption {
      type = types.str;
      description = ''
        WireGuard interface to use (wgX)
      '';
    };

    privateKeyFile = mkOption {
      type = types.str;
      description = ''
        path pointing to the WireGuard private key
      '';
    };

    firewall = mkOption {
      default = { };
      type = types.submodule {
        options = {
          allowedTCPPorts = mkOption {
            type = types.listOf types.port;
            default = [ ];
          };

          allowedTCPPortRanges = mkOption {
            type = types.listOf (types.attrsOf types.port);
            default = [ ];
          };

          allowedUDPPorts = mkOption {
            type = types.listOf types.port;
            default = [ ];
          };

          allowedUDPPortRanges = mkOption {
            type = types.listOf (types.attrsOf types.port);
            default = [ ];
          };

        };
      };
      description = ''
        firewall options that will be applied to each GRE interface
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    let
      # returns all hosts that can be reached from a given host
      reachableHostsFromHost =
        host:
        let
          hostReachableNetworks = cfg.config.hosts."${host}".reachableNetworks;
        in
        (lib.filterAttrs (
          hname: h:
          # we don't want an infinite loop lmao
          (hname != host)
          # Check if any of the networks the *other* host is in
          # is listed in the current host's reachableNetworks
          && (builtins.any (x: builtins.elem x hostReachableNetworks) (builtins.attrNames h.networks))
        ) cfg.config.hosts);

      # returns all hosts that can reach a given host
      hostsThatCanReachHost =
        host:
        let
          hostNetworks = builtins.attrNames cfg.config.hosts."${host}".networks;
        in
        (lib.filterAttrs (
          hname: h:
          # we don't want an infinite loop lmao
          (hname != host)
          # Check if any network that the current host is in
          # is listed in the other host's reachableNetworks
          && (builtins.any (x: builtins.elem x hostNetworks) (h.reachableNetworks))
        ) cfg.config.hosts);

      # get the endpoint on a host for a given peer
      peerEndpoint =
        host: peer:
        let
          peerHost = cfg.config.hosts."${peer}";
          # Networks the current host can reach
          hostReachableNetworks = cfg.config.hosts."${host}".reachableNetworks;
          # Networks the peer is in
          peerNetworks = peerHost.networks;
          # The first network that is in hostReachableNetworks and peerNetworks
          firstReachablePeerNetwork =
            peerNetworks.${
              builtins.head (
                builtins.filter (x: builtins.elem x hostReachableNetworks) (builtins.attrNames peerNetworks)
              )
            };
        in
        "${builtins.head firstReachablePeerNetwork.ips}:${builtins.toString peerHost.port}";

      currentHostName = config.networking.hostName;
      currentHost = cfg.config.hosts."${currentHostName}";

      # GRE stuff
      # TODO: refactor this, this was for networking.greTunnels and we use systemd-networkd now...
      # after refactoring this may be significantly simpler
      greCreate = peerName: peer: {
        remote = cfg.config.getPeerIntIp peer.peerId 0 0 false false false;
        local = cfg.config.getPeerIntIp currentHost.peerId 0 0 false false false;
      };
      # NOTE: we deduplicate based on remote (a host can appear in both reachableHostsFromHost and hostsThatCanReachHost)
      greInterfaceList =
        let
          uniqueByAttr =
            attr: list:
            lib.reverseList (
              lib.foldl' (
                acc: item:
                let
                  alreadySeen = lib.any (x: x.${attr} == item.${attr}) acc;
                in
                if alreadySeen then acc else acc ++ [ item ]
              ) [ ] (lib.reverseList list)
            );
        in
        uniqueByAttr "remote" (
          (lib.attrsets.mapAttrsToList greCreate (reachableHostsFromHost currentHostName))
          ++ (lib.attrsets.mapAttrsToList greCreate (hostsThatCanReachHost currentHostName))
        );
      greInterfaces =
        withIdx:
        builtins.listToAttrs (
          builtins.map (i: {
            # TODO: better interface names (let the user choose!)
            name = "gre${builtins.toString (i + 1)}";
            value = (builtins.elemAt greInterfaceList i) // (if withIdx then { idx = i; } else { });
          }) (lib.range 0 ((builtins.length greInterfaceList) - 1))
        );
    in
    {
      ## systemd-networkd
      # currently systemd-networkd is exclusively used for this wireguard stuff, so it's placed here.
      # If it's used anywhere else later maybe this should be moved? Honestly idk though..
      systemd.network.enable = true;
      systemd.network.wait-online.enable = false; # systemd-networkd does not handle our connection to the internet so this would be broken otherwise
      # systemd-networkd automatically enables systemd-resolved which we DO NOT want especially on servers that run nameservers..
      services.resolved.enable = false;

      # big thanks to https://www.kepstin.caa/blog/babel-routing-over-wireguard-for-the-tubes/ :3
      # and https://www.privateproxyguide.com/creating-a-vpn-based-mesh-network-using-babel-and-wireguard/

      ## Open port for WireGuard

      networking.firewall = {
        allowedUDPPorts = [ currentHost.port ];
      };

      ## WireGuard and GRE interfaces

      systemd.network.netdevs =
        {
          "30-${cfg.interface}" = {
            netdevConfig = {
              Kind = "wireguard";
              Name = "${cfg.interface}";
            };
            wireguardConfig = {
              PrivateKeyFile = cfg.privateKeyFile;
              ListenPort = currentHost.port;
              RouteTable = "main";
            };
            wireguardPeers =
              let
                peerDefaults = peerName: peer: {
                  PublicKey = peer.publicKey;
                  AllowedIPs = [
                    (cfg.config.getPeerIntIp peer.peerId 0 0 false true true)
                  ];
                  PersistentKeepalive = 25;
                };
              in
              (lib.attrsets.mapAttrsToList (
                peerName: peer:
                {
                  Endpoint = peerEndpoint currentHostName peerName;
                }
                // (peerDefaults peerName peer)
              ) (reachableHostsFromHost currentHostName))
              ++ (lib.attrsets.mapAttrsToList peerDefaults (hostsThatCanReachHost currentHostName));
          };
        }
        // builtins.listToAttrs (
          lib.attrsets.mapAttrsToList (n: v: {
            name = "20-${n}";
            value = {
              netdevConfig = {
                Kind = "gre";
                Name = "${n}";
              };
              tunnelConfig = {
                Local = v.local;
                Remote = v.remote;
              };
            };
          }) (greInterfaces true)
        );

      systemd.network.networks =
        {
          "30-${cfg.interface}" = {
            matchConfig.Name = "${cfg.interface}";
            address = [ (cfg.config.getPeerIntIp currentHost.peerId 0 0 true true false) ];
            tunnel = lib.attrsets.mapAttrsToList (n: v: "${n}") (greInterfaces true);
          };
        }
        // builtins.listToAttrs (
          lib.attrsets.mapAttrsToList (n: v: {
            name = "20-${n}";
            value = {
              matchConfig.Name = "${n}";
              address =
                [
                  ("${cfg.config.getPeerIntIp currentHost.peerId 1 (1 + v.idx) false false false}/32")
                  # Babel link-local address
                  # We do this manually because systemd-networkd LinkLocalAddressing seems to be borked for GRE interfaces??? idfk
                  (cfg.config.getV6LinkLocal currentHost.peerId)
                ]
                ++ (
                  if v.idx == 0 then
                    [
                      ("${currentHost.meshNodeAddress}/32")
                    ]
                  else
                    [ ]
                );
            };
          }) (greInterfaces true)
        );

      ## Routing

      # NOTE: routing in the kernel is enabled for us by babeld!
      services.babeld = {
        enable = true;
        interfaceDefaults = {
          "v4-via-v6" = "false";
        };
        interfaces = (
          builtins.listToAttrs (
            builtins.map (n: {
              name = n;
              value = { };
            }) (builtins.attrNames (greInterfaces false))
          )
        );
        # FIXME: will the random-id be okay - esp since this is NixOS? docs say
        # "the default is to use persistent router-ids derived from the MAC address of the first interface"
        # FIXME: hardcoded 172.26.x.x IPs are no good. Should be user-controlled
        extraConfig = ''
          protocol-port 6696
          random-id true
          debug 2

          in ip ${cfg.config.meshv4NetworkAddress} allow
          in ip 172.26.0.0/16 allow
          in deny

          out ip ${cfg.config.meshv4NetworkAddress} allow
          out ip 172.26.0.0/16 allow
          out deny

          redistribute ip ${cfg.config.meshv4NetworkAddress} allow
          redistribute ip 172.26.0.0/16 allow
          redistribute deny

          install ip ${cfg.config.meshv4NetworkAddress} allow
          install ip 172.26.0.0/16 allow
          install deny
        '';
      };

      # firewall for all GRE interfaces
      networking.firewall.interfaces = builtins.listToAttrs (
        lib.attrsets.mapAttrsToList (n: v: {
          name = n;
          value = {
            allowedTCPPorts = cfg.firewall.allowedTCPPorts;
            allowedTCPPortRanges = cfg.firewall.allowedTCPPortRanges;
            allowedUDPPorts = cfg.firewall.allowedUDPPorts ++ [
              6696 # allow babeld UDP port for the interfaces it uses
            ];
            allowedUDPPortRanges = cfg.firewall.allowedUDPPortRanges;
          };
        }) (greInterfaces true)
      );
    }
  );
}
