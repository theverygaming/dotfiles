{ config, flakeInputs, ... }:

{
  sops.secrets.wireguard_private = {
    neededForUsers = true;
    sopsFile = flakeInputs.secrets + "/hosts/${config.networking.hostName}/wireguard.yaml";
  };

  custom.wg_mesh = {
    enable = true;
    interface = "wgm0";
    privateKeyFile = config.sops.secrets.wireguard_private.path;
    config = {
      meshv4PrefixLength = 24;
      getPeerIntIp = peerId: offset: isInterfaceAddr: withSubnetMask: isNetworkAddress: "172.25.${builtins.toString peerId}.${builtins.toString (if isNetworkAddress then 0 else (offset + 1))}${(if withSubnetMask then (if isInterfaceAddr then "/16" else "/24") else "")}";
      hosts = {
        "vps-1" = {
          peerId = 1;
          publicKey = "3L9OTQ9q534ouK1pn1g2xq9foAOiFU9NDOS3kMT1siE=";
          port = 65436;
          meshNodeAddress = "10.13.12.1";
          networks = {
            "internet" = {
              ips = [
                "159.69.26.5"
              ];
            };
          };
          reachableNetworks = [ "internet" ];
        };
        "foxnix" = {
          peerId = 2;
          publicKey = "OkFYdhclX4kykKHV1AZ+Nlh+mHfiNmhyQ/3kd1Su1yY=";
          port = 65436;
          meshNodeAddress = "10.13.12.2";
          networks = {
            "foxden" = {
              ips = [
                "10.0.0.123"
              ];
            };
          };
          reachableNetworks = [ "internet" "foxden" ];
        };
        "foxportable" = {
          peerId = 3;
          publicKey = "61OX9FRj85BXMM2nl/teQd0IhURVjmxuXriqp8VEKGw=";
          port = 65436;
          meshNodeAddress = "10.13.12.3";
          networks = {};
          reachableNetworks = [ "internet" "foxden" ];
        };
      };
    };
  };
}
