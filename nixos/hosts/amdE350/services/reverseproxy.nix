{ flakeInputs, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    80 # HTTP
    443 # HTTPS
  ];

  services.caddy = {
    enable = true;
    globalConfig = ''
      metrics
      acme_ca https://ca.local.services.theverygaming.furrypri.de:8443/acme/acme/directory
    '';
    virtualHosts = {
      "amde350.local.infra.theverygaming.furrypri.de".extraConfig = ''
        reverse_proxy 10.69.0.2:8069
        reverse_proxy /websocket* 10.69.0.2:8072
      '';
    };
  };

  custom.monitoring.promScrapeTargets = [
    # Caddy
    "127.0.0.1:2019"
  ];
}
