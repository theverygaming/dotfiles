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

      fonts.packages = [
        pkgs.nerd-fonts.symbols-only
      ];

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

            programs.swaylock = {
              enable = true;
              settings = {
                ignore-empty-password = true;
                show-failed-attempts = true;
                daemonize = true;
                image = toString (
                  pkgs.runCommand "background-blurred" { } ''
                    ${pkgs.imagemagick}/bin/convert ${background} -blur 0x6 $out
                  ''
                );
                scaling = "fill";
                color = "000000";
                show-keyboard-layout = true;
              };
            };

            services.swayidle = {
              enable = true;
              events = {
                before-sleep = "${pkgs.swaylock}/bin/swaylock";
              };
              timeouts = [
                {
                  timeout = 1200;
                  command = "${pkgs.swayfx}/bin/swaymsg output \\* dpms off";
                  resumeCommand = "${pkgs.swayfx}/bin/swaymsg output \\* dpms on";
                }
                {
                  timeout = 1200;
                  command = "${pkgs.swaylock}/bin/swaylock";
                }
              ];
            };

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
                  "${modifier}+Shift+s" = "exec grim -g \"$(slurp)\" - | wl-copy";
                  "${modifier}+l" = "exec swaylock";
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
                    "custom/separator"
                    "custom/power"
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
                    format = "M {percentage:3}%";
                  };

                  "network" = {
                    interval = 5;
                    format = "󰛳 {bandwidthTotalBits}";
                    format-ethernet = " {bandwidthTotalBits}";
                    format-wifi = "{icon} {bandwidthTotalBits}";
                    format-icons = [
                      "󰤟"
                      "󰤢"
                      "󰤥"
                      "󰤨"
                    ];
                    min-length = 11;
                  };

                  "pulseaudio" = rec {
                    format = "{icon} {volume}% {format_source}";
                    # TODO: format-bluetooth
                    format-source = "M {volume}%";
                    format-icons = [ "A" ];
                  };

                  "custom/power" = {
                    format = "⏻";
                    tooltip = false;
                    menu = "on-click";
                    menu-file = pkgs.writeText "waybar-power-menufile" ''
                      <?xml version="1.0" encoding="UTF-8"?>
                      <interface>
                        <object class="GtkMenu" id="menu">
                          <child>
                            <object class="GtkMenuItem" id="lock">
                              <property name="label">Lock</property>
                            </object>
                          </child>
                          <child>
                            <object class="GtkSeparatorMenuItem" id="sep1"/>
                          </child>
                          <child>
                            <object class="GtkMenuItem" id="suspend">
                              <property name="label">Suspend</property>
                            </object>
                          </child>
                          <child>
                            <object class="GtkSeparatorMenuItem" id="sep2"/>
                          </child>
                          <child>
                            <object class="GtkMenuItem" id="reboot">
                              <property name="label">Reboot</property>
                            </object>
                          </child>
                          <child>
                            <object class="GtkMenuItem" id="shutdown">
                              <property name="label">Shutdown</property>
                            </object>
                          </child>
                        </object>
                      </interface>
                    '';
                    menu-actions = {
                      lock = "swaylock";
                      suspend = "systemctl suspend";
                      reboot = "reboot";
                      shutdown = "shutdown";
                    };
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
