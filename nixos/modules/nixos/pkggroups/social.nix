{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.pkggroups.social;
in
{
  options.custom.pkggroups.social = {
    enable = lib.mkEnableOption "Enable Social packages";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      discord
      telegram-desktop
      element-desktop
      signal-desktop
    ];
  };
}
