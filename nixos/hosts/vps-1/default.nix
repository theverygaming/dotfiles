{ flakeInputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ../../common
    ../../users
  ];

  custom.profiles.server.enable = true;

  deployment = {
    targetHost = "vps-1.infra.test.furrypri.de";
    targetPort = 2222;
    targetUser = "root";
  };

  boot.loader = {
    efi = {
      canTouchEfiVariables = false;
      efiSysMountPoint = "/boot/efi";
    };
    systemd-boot.enable = true;
  };

  # Networking
  networking.hostName = "vps-1";
  networking.networkmanager.enable = true;

  # DNS
  services.nsd = {
    enable = true;
    interfaces = [
      "0.0.0.0"
      "::"
    ];
    zones = {
      "test.furrypri.de" = {
        data = flakeInputs.dns.lib.toString "test.furrypri.de" (with flakeInputs.dns.lib.combinators; {
          TTL = 300;
          SOA = {
            #nameServer = "ns1"; # TODO: ns1.test.furrypri.de should be a thing! :3
            nameServer = "theverygaming.furrypri.de.";
            adminEmail = "dnsadmin@theverygaming.furrypri.de";
            serial = 2025032100; # The recommended syntax is YYYYMMDDnn (YYYY=year, MM=month, DD=day, nn=revision number
            refresh = 60 * 60;
            retry = 60 * 30;
            expire = 60 * 60 * 24;
          };

          CAA = letsEncrypt "ssladmin@theverygaming.furrypri.de";  # Common template combinators included

          subdomains = {
            "infra" = {
              subdomains = {
                "vps-1" = {
                  A = [
                    "188.34.191.96"
                  ];
                  # TODO: AAAA
                };
              };
            };
          };
        });
      };
    };
  };
}
