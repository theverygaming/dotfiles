{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.public_webserver;
in
{
  options.custom.public_webserver = {
    enable = lib.mkEnableOption "Enable public webserver on /srv/http/public";
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      virtualHosts.":80".extraConfig = ''
        encode gzip
        file_server browse
        root * /srv/http/public
      '';
    };
    networking.firewall.allowedTCPPorts = [ 80 ];

    systemd.tmpfiles.rules = [
      "d /srv/http/public 0775 root users -"
    ];
  };
}
