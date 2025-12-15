{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.pkggroups.gaming;
in
{
  options.custom.pkggroups.gaming = {
    enable = lib.mkEnableOption "Enable Gaming packages";
  };

  config = lib.mkIf cfg.enable {
    #  programs.steam = {
    #    enable = true;
    #    remotePlay.openFirewall = true;
    #    dedicatedServer.openFirewall = true;
    #  };
    environment.systemPackages = with pkgs; [
      prismlauncher # minecraft
    ];
  };
}
