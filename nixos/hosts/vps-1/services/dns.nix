{ flakeInputs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    53 # DNS
  ];
  networking.firewall.allowedUDPPorts = [
    53 # DNS
  ];

  services.nsd = {
    enable = true;
    interfaces = [
      "0.0.0.0"
      "::"
    ];
    zones =
      let
        getZone = (import ../../../dns.nix { inherit flakeInputs; }).getZone;
      in
      {
        "m.furrypri.de" = {
          data = flakeInputs.dns.lib.toString "m.furrypri.de" (getZone "m.furrypri.de");
        };
        "theverygaming.furrypri.de" = {
          data = flakeInputs.dns.lib.toString "theverygaming.furrypri.de" (
            getZone "theverygaming.furrypri.de"
          );
        };
      };
  };
}
