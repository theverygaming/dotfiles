{ config, lib, pkgs, ... }:

let
  cfg = config.custom.profiles.desktop;
in {
  options.custom.profiles.desktop = {
    enable = lib.mkEnableOption "Enable Desktop profile";
  };

  config = lib.mkIf cfg.enable {
    custom = {
      profiles.base.enable = lib.mkDefault true;

      pkggroups = {
        browsers.enable = lib.mkDefault true;
        containerization.enable = lib.mkDefault true;
        dev.enable = lib.mkDefault true;
        electronics.enable = lib.mkDefault true;
        gaming.enable = lib.mkDefault true;
        media.enable = lib.mkDefault true;
        office.enable = lib.mkDefault true;
        radio.enable = lib.mkDefault true;
        social.enable = lib.mkDefault true;
        k8sadmin.enable = lib.mkDefault true;
        avstuff.enable = lib.mkDefault true;
      };
    };
  };
}
