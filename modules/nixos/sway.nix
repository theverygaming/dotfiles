{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.wm.sway;
in
{
  options.custom.wm.sway = {
    enable = lib.mkEnableOption "Enable sway window manager";
  };

  config = lib.mkIf cfg.enable {
    security.polkit.enable = true;

    services.gnome.gnome-keyring.enable = true;

    # TODO: this should be independent from the desktop stuff..
    services.displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };

    programs.sway = {
      enable = true;
      package = pkgs.swayfx;
      wrapperFeatures.gtk = true;
      extraOptions = [
        "--unsupported-gpu"
      ];
    };
  };
}
