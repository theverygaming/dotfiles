{ pkgs, lib, ... }:

let
  # TODO: centralize background config!
  background = pkgs.fetchurl {
    url = "https://xenia.chimmie.k.vu/art/bin/xenia_drawing5-1.png";
    hash = "sha256-5G1QJ75aDCQsdmdZE95rZN7Yj9yyIshhdjGAzDMykos=";
  };
in
{
  home.packages = with pkgs; [
    kitty
    swaybg
    wofi
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    checkConfig = false; # config check fails with: Cannot create GLES2 renderer: no DRM FD available (probably a swayfx issue?)
    config = rec {
      modifier = "Mod4"; # super key
      terminal = "kitty";
      menu = "wofi --show run";
      window.titlebar = false;

      defaultWorkspace = "workspace number 1"; # TODO: figure out workspaces..

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

      ## eye candy starts here
      colors = {
        focused = {
          background = "#FFFFFF";
          border = "#9B59D0";
          childBorder = "#9B59D0";
          indicator = "#9B59D0";
          text = "#FFFFFF";
        };
      };
      gaps = {
        smartGaps = false;
        inner = 10;
      };
      ## eye candy ends here
    };
    # layer_effects "waybar" corner_radius 0
    extraConfig = (
      ## eye candy starts here
      ''
        output * bg ${background} fill

        blur enable
        blur_passes 3
        blur_radius 2
        blur_noise 0.1
        blur_brightness 1.0
        blur_contrast 1.0
        blur_saturation 1.0

        corner_radius 10

        shadows disable
      ''
      ## eye candy ends here
    );
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
          "tray"
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
    style = '''';
  };
}
