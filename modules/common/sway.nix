{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.desktop.sway;
in
{
  options.custom.desktop.sway = {
    enable = lib.mkEnableOption "Enable sway desktop";
    monitor_cfg = lib.mkOption {
      default = "";
      type = lib.types.str;
      description = ''
        sway monitor configuration
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
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

      home-manager.sharedModules = [
        (
          {
            pkgs,
            lib,
            osConfig,
            config,
            ...
          }:
          let
            background = config.custom.desktop.background;
          in
          {
            home.packages = with pkgs; [
              kitty
              swaybg
              wofi
              grim
              slurp
              wl-clipboard
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
                  inner = 5;
                };
                keybindings = lib.mkOptionDefault {
                  # screenshot
                  "${modifier}+Shift+s" = ''exec grim -g "$(slurp)" - | wl-copy'';
                };
              };

              extraConfig = ''
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
              + cfg.monitor_cfg;
            };

            programs.waybar = {
              enable = true;
              settings = {
                mainBar = {
                  layer = "top";
                  position = "top";
                  margin-top = 5;
                  margin-left = 10;
                  margin-right = 10;
                  height = 34;
                  spacing = 0;
                  modules-left = [
                    "sway/workspaces"
                    "sway/mode"
                    "sway/window"
                  ];
                  modules-center = [ "clock" ];
                  modules-right = [
                    "tray"
                    "custom/separator"
                    "pulseaudio"
                    "backlight"
                    "custom/separator"
                    "battery"
                    "temperature"
                    "cpu"
                    "memory"
                    "network"
                  ];

                  "sway/workspaces" = {
                    disable-scroll = true;
                    all-outputs = true;
                  };

                  "clock" = {
                    format = "C {:%Y-%m-%dT%T%z}";
                    interval = 1;
                  };

                  "custom/separator" = {
                    format = "|";
                    interval = "once";
                    tooltip = false;
                  };

                  "cpu" = {
                    interval = 1;
                    format = "C {usage:3}%";
                  };

                  "memory" = {
                    interval = 5;
                    format = "M {used:4.1f}GiB";
                  };

                  "network" = {
                    interval = 5;
                    format = "N {bandwidthTotalBits}";
                    min-length = 11;
                  };

                  "pulseaudio" = rec {
                    format = "{icon} {volume}% {format_source}";
                    # TODO: format-bluetooth
                    format-source = "M {volume}%";
                    format-icons = [ "A" ];
                  };
                };
              };
              style = ''
                * {
                  font-family: ${
                    lib.concatStringsSep ", " (
                      map (x: "\"${x}\"") (
                        if config.fonts.fontconfig.defaultFonts.monospace != [ ] then
                          config.fonts.fontconfig.defaultFonts.monospace
                        else
                          osConfig.fonts.fontconfig.defaultFonts.monospace
                      )
                    )
                  };
                }

                window#waybar {
                  background-color: rgba(50, 50, 50, 0.4);
                  color: #ffffff;
                  border-radius: 10px;
                }

                .modules-left, .modules-center, .modules-right {
                  padding: 0 10px;
                }

                .module {
                  margin: 0 5px;
                }

                #custom-separator {
                  color: #9B59D0;
                }
              '';
            };

            home.pointerCursor = {
              name = "macOS";
              package = pkgs.apple-cursor;
              size = 22;
              sway.enable = true;
              x11.enable = true;
              gtk.enable = true;
            };
          }
        )
      ];
    })
    {
      home-manager.sharedModules = [
        {
          options.custom.desktop.sway = { };
        }
      ];
    }
  ];
}
