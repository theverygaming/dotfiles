{ config, lib, pkgs, ... }:

let
  cfg = config.custom.pkggroups.core;
in {
  options.custom.pkggroups.core = {
    enable = lib.mkEnableOption "Enable core packages";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wget
      htop
      unzip
      inetutils
      hyfetch # yeah this is a basic package you will always need
      psmisc
      lm_sensors
      tree
    ];
  };
}
