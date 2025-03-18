{ config, lib, pkgs, ... }:

let
  cfg = config.custom.pkggroups.browsers;
in {
  options.custom.pkggroups.browsers = {
    enable = lib.mkEnableOption "Enable Browser packages";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      firefox
      google-chrome # TODO: don't use that shit
    ];
  };
}
