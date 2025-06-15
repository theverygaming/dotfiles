{ flakeInputs }:

let
  zone_common = (
    with flakeInputs.dns.lib.combinators;
    {
      TTL = 300;
      SOA = {
        nameServer = "ns1.theverygaming.furrypri.de.";
        adminEmail = "m@screee.ee";
        serial = 2025061501; # The recommended syntax is YYYYMMDDnn (YYYY=year, MM=month, DD=day, nn=revision number
        refresh = 60 * 60;
        retry = 60 * 30;
        expire = 60 * 60 * 24;
      };

      CAA = letsEncrypt "m@screee.ee";
    }
  );
in
{
  getZone =
    zone:
    builtins.getAttr zone {
      "m.furrypri.de" = (
        with flakeInputs.dns.lib.combinators;
        {
          # TODO: AAAA
          A = [
            "159.69.26.5"
          ];
        }
        // zone_common
      );
      "theverygaming.furrypri.de" = (
        with flakeInputs.dns.lib.combinators;
        {
          # TODO: AAAA
          A = [
            "159.69.26.5"
          ];

          subdomains = {
            "ns1" = {
              # TODO: AAAA
              A = [
                "159.69.26.5"
              ];
            };

            "services" = {
              subdomains = {
                "local" = {
                  subdomains = {
                    "ca" = {
                      A = [
                        "10.13.12.1"
                      ];
                    };
                  };
                };
              };
            };

            # FIXME: this is ass, refine DNS
            "infra" = {
              subdomains = {
                "lan" = {
                  subdomains = {
                    "amdE350" = {
                      A = [
                        "192.168.178.39"
                      ];
                    };
                  };
                };
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
        // zone_common
      );
    };
}
