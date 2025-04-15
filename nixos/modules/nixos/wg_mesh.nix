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
              Returns an IP address string in CIDR notation based on the given peerID, offset and the isInterfaceAddr, isNetworkAddress and withSubnetMask flags
              - If isInterfaceAddr is false, it returns either an IPv4 (/24) or IPv6 (/128) address assigned to the peer
              - If isInterfaceAddr is true, it returns the same address as above, but with the full internal network
                subnet (IPv4 or IPv6) assigned to the peer's WireGuard interface
              This address is used internally for configuring the WireGuard interface on the specified peer
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

                    int = {
                      addrv4prefix = mkOption {
                        type = types.str;
                        description = "Internal WireGuard IPv4 address prefix";
                      };
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
      greCreate = peerName: peer: {
        type = "tun";
        remote = cfg.config.getPeerIntIp peer.peerId 0 false false false;
        local = cfg.config.getPeerIntIp currentHost.peerId 0 false false false;
        dev = cfg.interface;
      };
      greInterfaceList =
        (lib.attrsets.mapAttrsToList greCreate (reachableHostsFromHost currentHostName))
        ++ (lib.attrsets.mapAttrsToList greCreate (hostsThatCanReachHost currentHostName));
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
      # big thanks to https://www.kepstin.ca/blog/babel-routing-over-wireguard-for-the-tubes/ :3
      # and https://www.privateproxyguide.com/creating-a-vpn-based-mesh-network-using-babel-and-wireguard/

      ## WireGuard

      networking.firewall = {
        allowedUDPPorts = [ currentHost.port ];
      };

      networking.wireguard.enable = true;

      networking.wireguard.interfaces."${cfg.interface}" = {
        ips = [ (cfg.config.getPeerIntIp currentHost.peerId 0 true true false) ];
        listenPort = currentHost.port;

        privateKeyFile = cfg.privateKeyFile;

        peers =
          let
            peerDefaults = peerName: peer: {
              name = peerName;
              publicKey = peer.publicKey;
              allowedIPs = [
                (cfg.config.getPeerIntIp peer.peerId 0 false true true)
              ];
              persistentKeepalive = 25;
            };
          in
          (lib.attrsets.mapAttrsToList (
            peerName: peer:
            {
              endpoint = peerEndpoint currentHostName peerName;
            }
            // (peerDefaults peerName peer)
          ) (reachableHostsFromHost currentHostName))
          ++ (lib.attrsets.mapAttrsToList peerDefaults (hostsThatCanReachHost currentHostName));
      };

      ## GRE and network interfaces

      networking.greTunnels = greInterfaces false;

      networking.interfaces = builtins.listToAttrs (
        lib.attrsets.mapAttrsToList (n: v: {
          name = n;
          value = {
            ipv4.addresses = (
              if v.idx == 0 then
                [
                  {
                    address = currentHost.meshNodeAddress;
                    prefixLength = 32;
                  }
                ]
              else
                [ ]
            );
            tempAddress = "default"; # should generate a link-local IPv6 address?
          };
        }) (greInterfaces true)
      );

      ## Routing

      # NOTE: routing in the kernel is enabled for us by babeld!
      services.babeld = {
        enable = true;
        interfaceDefaults = { };
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
        extraConfig = ''
          protocol-port 6696
          random-id true

          in ip ${cfg.config.meshv4NetworkAddress} allow
          in deny

          out ip ${cfg.config.meshv4NetworkAddress} allow
          out deny

          redistribute ip ${cfg.config.meshv4NetworkAddress} allow
          redistribute deny

          install ip ${cfg.config.meshv4NetworkAddress} allow
          install deny
        '';
      };

      # allow babeld UDP port for the interfaces it uses
      networking.firewall.interfaces = builtins.listToAttrs (
        lib.attrsets.mapAttrsToList (n: v: {
          name = n;
          value = {
            allowedUDPPorts = [ 6696 ];
          };
        }) (greInterfaces true)
      );
    }
  );
}
