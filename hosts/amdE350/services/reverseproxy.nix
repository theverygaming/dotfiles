{ flakeInputs, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    80 # HTTP
    443 # HTTPS
  ];

  services.caddy = {
    enable = true;
    virtualHosts = {
      "http://amdE350.lan.infra.theverygaming.furrypri.de".extraConfig = ''
        reverse_proxy 10.69.0.2:8069
        reverse_proxy /websocket* 10.69.0.2:8072
      '';
    };
  };
}
