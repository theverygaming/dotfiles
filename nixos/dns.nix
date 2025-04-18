{ flakeInputs }:

{
  getZone =
    zone:
    builtins.getAttr zone {
      "test.furrypri.de" = (
        with flakeInputs.dns.lib.combinators;
        {
          TTL = 300;
          SOA = {
            #nameServer = "ns1"; # TODO: ns1.test.furrypri.de should be a thing! :3
            nameServer = "theverygaming.furrypri.de.";
            adminEmail = "dnsadmin@theverygaming.furrypri.de";
            serial = 2025041800; # The recommended syntax is YYYYMMDDnn (YYYY=year, MM=month, DD=day, nn=revision number
            refresh = 60 * 60;
            retry = 60 * 30;
            expire = 60 * 60 * 24;
          };

          CAA = letsEncrypt "ssladmin@theverygaming.furrypri.de";

          subdomains = {
            "infra" = {
              subdomains = {
                "local" = {
                  subdomains = {
                    "vps-1" = {
                      A = [
                        "10.13.12.1"
                      ];
                    };
                    "foxnix" = {
                      A = [
                        "10.13.12.2"
                      ];
                    };
                    "foxportable" = {
                      A = [
                        "10.13.12.3"
                      ];
                    };
                    "amdE350" = {
                      A = [
                        "10.13.12.4"
                      ];
                    };
                  };
                };
                "vps-1" = {
                  A = [
                    "159.69.26.5"
                  ];
                  # TODO: AAAA
                };
                "vps-old" = {
                  A = [
                    "128.140.1.26"
                  ];
                };
              };
            };
          };
        }
      );
    };
}
