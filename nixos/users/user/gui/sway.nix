{ pkgs, lib, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    package = null; # apparently only generates config and stuff
    config = rec {
      modifier = "Mod4"; # windows key
      terminal = "xfce4-terminal";
      menu = "wofi --show run";
      window.titlebar = false;

      defaultWorkspace = "workspace number 1";

      bars = [
        {
          command = "waybar";
        }
      ];

      input = {
        "*" = {
          tap = "enabled"; # tap to click
        };
      };
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        modules-left = [
          "sway/workspaces"
          "sway/mode"
          "wlr/taskbar"
        ];
        modules-center = [ "sway/window" ];
        modules-right = [
          "pulseaudio"
          "battery"
          "temperature"
          "cpu"
          "memory"
          "network"
          "clock"
        ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };
      };
    };
  };
}
