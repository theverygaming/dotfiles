{ pkgs, lib, ... }:

{
  xfconf.settings = {
    xsettings = {
      "/Net/ThemeName" = "Adwaita-dark";
      "/Net/IconThemeName" = "Adwaita";
    };

    xfce4-desktop = {
      #"/backdrop/screen0/monitoreDP-1/workspace0/last-image" = ""; # TODO: fetch background image
    };

    xfce4-notifyd = {
      "/notification-log" = true;
      "/log-level" = "always";
      "/log-level-apps" = "all";
      "/log-max-size" = 1000;
    };

    xfce4-screensaver = {
      "/saver/enabled" = true;
      "/saver/mode" = 0; # blank screen
      "/lock/saver-activation/delay" = 1; # lock screen after 1min of screensaver
      "/saver/idle-activation/delay" = 1; # activate screensaver after 1min
    };

    xfce4-power-manager = {
      "/xfce4-power-manager/general-notification" = true;
      "/xfce4-power-manager/show-tray-icon" = true;
    };
  };
}
