{ pkgs, lib, plasma-manager, ... }:

let
  mainPanel = {
    height = 40;
    location = "bottom";
    widgets = [
      "org.kde.plasma.kickoff"
      "org.kde.plasma.pager"
      {
        name = "org.kde.plasma.icontasks";
        config = {
          General.launchers = [
            "applications:org.kde.dolphin.desktop"
            "applications:google-chrome.desktop"
            "applications:firefox.desktop"
            "applications:discord.desktop"
            "applications:org.telegram.desktop.desktop"
            "applications:element-desktop.desktop"
            "applications:code.desktop"
            "applications:org.kde.konsole.desktop"
            "applications:org.pipewire.Helvum.desktop"
          ];
        };
      }
      "org.kde.plasma.systemtray"
      {
        name = "org.kde.plasma.digitalclock";
        config = {
          Appearance.showSeconds = "Always";
        };
      }
    ];
  };
in
{
  imports = [ plasma-manager.homeManagerModules.plasma-manager ];

  programs.plasma = {
    enable = true;
    overrideConfig = true;

    workspace = {
      clickItemTo = "select";
      tooltipDelay = 5;
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      # NOTE: broken
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Next/contents/images_dark/1080x1920.png";
    };

    spectacle.shortcuts = {
      captureRectangularRegion = "Meta+Shift+S";
      recordRegion = "Meta+Shift+R";
      launchWithoutCapturing = "Print";
    };

    kwin.titlebarButtons = {
      left = [ ];
      right = [ "minimize" "maximize" "close" ];
    };

    panels = [
      mainPanel
    ];

    configFile = {
      kcminputrc = {
        Keyboard.RepeatDelay = 600;
        Keyboard.RepeatRate = 30;
        Mouse.X11LibInputXAccelProfileFlat = true;
      };
      kxkbrc.Layout = {
        Displaynames = ",";
        LayoutList = "us,de";
        Use = true;
        VariantList = ",nodeadkeys";
      };
      kwinrc.NightColor = {
        Active = true;
        LatitudeFixed = 48.45;
        LongitudeFixed = 10.86;
        Mode = "Location";
      };
    };

    shortcuts = {
      "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Ctrl+Space";
    };
  };
}
