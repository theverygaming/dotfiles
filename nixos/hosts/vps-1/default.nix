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
    # also vps-1.infra.test.furrypri.de but the DNS for
    # test.furrypri.de runs there and is a bit unreliable
    # for the time being sooo lets use something else for now
    targetHost = "theverygaming.furrypri.de";
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
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
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

          CAA = letsEncrypt "ssladmin@theverygaming.furrypri.de";

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
