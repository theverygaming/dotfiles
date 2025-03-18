{ config, lib, pkgs, ... }:

let
  cfg = config.custom.profiles.base;
in {
  options.custom.profiles.base = {
    enable = lib.mkEnableOption "Enable Base profile";
  };

  config = lib.mkIf cfg.enable {
    custom.pkggroups.core.enable = lib.mkDefault true;
  };
}
