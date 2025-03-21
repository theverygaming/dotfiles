{ config, lib, pkgs, ... }:

let
  cfg = config.custom.profiles.server;
in {
  options.custom.profiles.server = {
    enable = lib.mkEnableOption "Enable Server profile";
  };

  config = lib.mkIf cfg.enable {
    custom = {
      profiles.base.enable = lib.mkDefault true;

      pkggroups = {
        containerization.enable = lib.mkDefault true;
      };

      flake_auto_upgrade.enable = true;
    };

    # TODO: fail2ban maybe?
    services.openssh = {
      enable = lib.mkDefault true;
      ports = lib.mkDefault [
        2222
      ];
      settings.PasswordAuthentication = lib.mkDefault false; # aw hell nah
    };
  };
}
