{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.desktops.i3;
in
{
  options.custom.desktops.i3 = {
    enable = lib.mkEnableOption "Enable i3 desktop";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        xfce.xfce4-terminal
        i3lock-fancy
      ];

      programs.dconf.enable = true;

      environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

      services.xserver = {
        enable = true;

        desktopManager = {
          xterm.enable = false;
        };

        windowManager.i3 = {
          enable = true;
          extraPackages = with pkgs; [
            dmenu # application launcher most people use
            i3status # gives you the default i3 status bar
            i3lock # default i3 screen locker
            i3blocks # if you are planning on using i3blocks over i3status
          ];
        };
      };

      services.displayManager = {
        defaultSession = "none+i3";
      };

      home-manager.sharedModules = [
        (
          {
            pkgs,
            lib,
            config,
            ...
          }:
          let
            cfg = config.custom.desktops.i3;
          in
          {

          }
        )
      ];
    })
    {
      home-manager.sharedModules = [
        {
          options.custom.desktops.i3 = { };
        }
      ];
    }
  ];
}
