{ config, flakeInputs, ... }:

{
  sops.secrets.wireguard_private = {
    neededForUsers = true;
    sopsFile = flakeInputs.secrets + "/hosts/${config.networking.hostName}/wireguard.yaml";
  };

  custom.wg_mesh = {
    enable = true;
    getInterface = n: "wgm${builtins.toString n}";
    privateKeyFile = config.sops.secrets.wireguard_private.path;
    config = {
      addrv4NetworkAddress = "10.69.0.0";
      addrv4PrefixLength = 16;
      hosts = {
        "vps-1" = {
          publicKey = "3L9OTQ9q534ouK1pn1g2xq9foAOiFU9NDOS3kMT1siE=";
          port = 65436;
          int = {
            addrv4prefix = "10.69.1";
          };
          networks = {
            "internet" = {
              ips = [
                {
                  type = "v4";
                  addr = "159.69.26.5";
                }
              ];
            };
          };
          reachableNetworks = [ "internet" ];
        };
        "foxnix" = {
          publicKey = "OkFYdhclX4kykKHV1AZ+Nlh+mHfiNmhyQ/3kd1Su1yY=";
          port = 65436;
          int = {
            addrv4prefix = "10.69.2";
          };
          networks = {
            "foxden" = {
              ips = [
                {
                  type = "v4";
                  addr = "10.0.0.123";
                }
              ];
            };
          };
          reachableNetworks = [ "internet" "foxden" ];
        };
        "foxportable" = {
          publicKey = "61OX9FRj85BXMM2nl/teQd0IhURVjmxuXriqp8VEKGw=";
          port = 65436;
          int = {
            addrv4prefix = "10.69.3";
          };
          networks = {};
          reachableNetworks = [ "internet" "foxden" ];
        };
      };
    };
  };
}
