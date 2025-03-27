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
  };
}
