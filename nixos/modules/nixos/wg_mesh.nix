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
            description = "IPv4 network address seen by the end user";
          };
          meshv4PrefixLength = mkOption {
            type = types.int;
            description = "IPv4 prefix length seen by the end user";
          };
          getPeerIntIp = mkOption {
            type = types.anything;
            description = ''
              Returns an IP address string in CIDR notation based on the given peerID and isInterfaceAddr flag
              - If isInterfaceAddr is false, it returns either an IPv4 (/32) or IPv6 (/128) address assigned to the peer
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

                    meshNetworkAddress = mkOption {
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
    in
    {
      # big thanks to https://www.kepstin.ca/blog/babel-routing-over-wireguard-for-the-tubes/ :3

      ## WireGuard

      networking.firewall = {
        allowedUDPPorts = [ currentHost.port ];
      };

      networking.wireguard.enable = true;

      networking.wireguard.interfaces."${cfg.interface}" = {
        ips = [ (cfg.config.getPeerIntIp currentHost.peerId true) ];
        listenPort = currentHost.port;

        privateKeyFile = cfg.privateKeyFile;

        peers =
          let
            peerDefaults = peerName: peer: {
              name = peerName;
              publicKey = peer.publicKey;
              allowedIPs = [
                (cfg.config.getPeerIntIp peer.peerId false)
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

      /*networking.wireguard.interfaces = builtins.listToAttrs (
        let
          interfaceGen =
            {
              peerName,
              peer,
              hasEndpoint,
              interfaceIdx,
            }:
            {
              ips = [
                "${currentHost.int.addrv4prefix}.${builtins.toString (interfaceIdx+1)}/32"
                # Babel link-local address
                "fe80:${
                  # Babel needs a link-local IPv6 address that is unique at least on each link.
                  # We generate an address based on this machine's name, which should be unique!
                  # I'm sorry. I started writing this at 05:30am and finished at 06:33am
                  # Also, this breaks if at least two machine's honstnames start with the same N (see below) characters
                  # but if that is the case i think something else is seriously wrong
                  let
                    strToBytes = str: builtins.map lib.strings.charToInt (lib.stringToCharacters str);
                    asciiByteToHex = ascii: (if ascii < 16 then "0" else "") + (lib.toHexString ascii);
                    byteArrToHexString = arr: builtins.foldl' (s: el: s + (asciiByteToHex el)) "" arr;
                    padString =
                      str: max: pad:
                      if builtins.stringLength str > max then
                        builtins.substring 0 max str
                      else
                        lib.concatStrings ([ str ] ++ (builtins.genList (_: pad) (max - (builtins.stringLength str))));
                    splitIntoChunks =
                      list: chunkSize:
                      builtins.foldl' (
                        acc: idx:
                        acc
                        ++ [
                          (lib.take chunkSize (lib.drop (idx * chunkSize) list))
                        ]
                      ) [ ] (lib.range 0 (((builtins.length list) / chunkSize) - 1));
                  in
                  if
                    lib.asserts.assertMsg
                      (
                        let
                          hosts = builtins.map (x: padString x (14 - 1) "e") (builtins.attrNames cfg.config.hosts);
                        in
                        !(builtins.any (s: (builtins.length (builtins.filter (x: x == s) hosts)) > 1) hosts)
                      )
                      "two hostnames start with the same 14-1 characters. This breaks the cursed wireguard link-local address assignment thingy"
                  then
                    lib.concatStringsSep ":" (
                      builtins.map byteArrToHexString (
                        splitIntoChunks (
                          [
                            (
                              if
                                (lib.asserts.assertMsg (
                                  interfaceIdx < 256
                                ) "link-local address assignment skill issue (interfaceIdx too high)!")
                              then
                                interfaceIdx
                              else
                                0
                            )
                          ]
                          ++ (strToBytes (padString currentHostName (14 - 1) "e"))
                        ) 2
                      )
                    )
                  else
                    "UNREACHABLE"
                }/16"
              ];
              listenPort = currentHost.port + interfaceIdx;

              privateKeyFile = cfg.privateKeyFile;

              allowedIPsAsRoutes = false; # Babel's job!

              peers = [
                (
                  {
                    name = peerName;
                    publicKey = peer.publicKey;
                    allowedIPs = [
                      "${cfg.config.addrv4NetworkAddress}/${builtins.toString cfg.config.addrv4PrefixLength}"
                      # Babel uses IPv6 link-local, unicast and multicast addresses
                      "fe80::/64"
                      "ff02::1:6/128"
                    ];
                    persistentKeepalive = 25;
                  }
                  // (
                    if hasEndpoint then
                      {
                        endpoint = peerEndpoint currentHostName peerName;
                      }
                    else
                      { }
                  )
                )
              ];

            };
          listReachableHostsFromHost = lib.attrsets.attrsToList (reachableHostsFromHost currentHostName);
          listReachableHostsFromHostLen = builtins.length listReachableHostsFromHost;
          listHostsCanReach = lib.attrsets.attrsToList (hostsThatCanReachHost currentHostName);
          listHostsCanReachLen = builtins.length listHostsCanReach;
        in
        (
          builtins.map (i: {
            name = cfg.getInterface i;
            value = interfaceGen (
              let
                el = builtins.elemAt listReachableHostsFromHost i;
              in
              {
                peerName = el.name;
                peer = el.value;
                hasEndpoint = true;
                interfaceIdx = i;
              }
            );
          }) (lib.range 0 (listReachableHostsFromHostLen - 1))
          ++ builtins.map (
            i:
            (
              let
                el = builtins.elemAt listHostsCanReach i;
              in
              {
                name = cfg.getInterface (i + listReachableHostsFromHostLen);
                value = interfaceGen {
                  peerName = el.name;
                  peer = el.value;
                  hasEndpoint = false;
                  interfaceIdx = i + listReachableHostsFromHostLen;
                };
              }
            )
          ) (lib.range 0 (listHostsCanReachLen - 1))
        )
      );*/

      ## Routing

      /*
        boot.kernel.sysctl = {
          "net.ipv4.conf.all.forwarding" = true;
          "net.ipv6.conf.all.forwarding" = true;
        };
      */
    }
  );
}
