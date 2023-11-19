{ config, pkgs, ... }:

{
  services.caddy = {
    enable = true;
    virtualHosts.":80".extraConfig = ''
      encode gzip
      file_server browse
      root * /srv/http
    '';
  };
  networking.firewall.allowedTCPPorts = [ 80 ];
}
