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
          addrv4NetworkAddress = mkOption {
            type = types.str;
            description = "IPv4 petwork address for the whole WireGuard network";
          };
          addrv4PrefixLength = mkOption {
            type = types.int;
            description = "IPv4 prefix length for the whole WireGuard network";
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

                    publicKey = mkOption {
                      type = types.str;
                      description = ''
                        WireGuard public key for this host
                      '';
                    };

                    int = {
                      addrv4 = mkOption {
                        type = types.str;
                        description = "Internal WireGuard IPv4 address";
                      };
                    };

                    networks = mkOption {
                      type = types.attrsOf (
                        types.submodule {
                          options = {
                            ips = mkOption {
                              type = types.listOf (
                                types.submodule {
                                  options = {
                                    type = mkOption {
                                      type = types.enum [ "v4" ];
                                      description = "IP type";
                                    };
                                    addr = mkOption {
                                      type = types.str;
                                      description = "IP address";
                                    };
                                  };
                                }
                              );
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
        "${(builtins.head firstReachablePeerNetwork.ips).addr}:${builtins.toString peerHost.port}";

      currentHostName = config.networking.hostName;
      currentHost = cfg.config.hosts."${currentHostName}";
    in
    {
      /*
        boot.kernel.sysctl = {
          "net.ipv4.conf.all.forwarding" = true;
          "net.ipv6.conf.all.forwarding" = true;
        };
      */

      networking.firewall = {
        allowedUDPPorts = [ currentHost.port ];
      };

      networking.wireguard.enable = true;
      networking.wireguard.interfaces."${cfg.interface}" = {
        ips = [ "${currentHost.int.addrv4}/${builtins.toString cfg.config.addrv4PrefixLength}" ];
        listenPort = currentHost.port;

        privateKeyFile = cfg.privateKeyFile;

        peers =
          let
            peerDefaults = peerName: peer: {
              name = peerName;
              publicKey = peer.publicKey;
              allowedIPs = [
                "${cfg.config.addrv4NetworkAddress}/${builtins.toString cfg.config.addrv4PrefixLength}"
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
    }
  );
}
