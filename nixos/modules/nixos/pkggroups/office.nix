{ config, lib, pkgs, ... }:

let
  cfg = config.custom.pkggroups.office;
in {
  options.custom.pkggroups.office = {
    enable = lib.mkEnableOption "Enable Office packages";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libreoffice-qt6-fresh
      marp-cli # Markdown presentation tool
    ];
  };
}
