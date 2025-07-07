{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.desktops.gnome;
in
{
  options.custom.desktops.gnome = {
    enable = lib.mkEnableOption "Enable GNOME desktop";
  };

  config = lib.mkIf cfg.enable {
    # Enable the GNOME Desktop Environment.
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    environment.gnome.excludePackages = (
      with pkgs;
      [
        gnome-tour
        gnome-photos
        cheese # webcam tool
        gnome-terminal
        epiphany # web browser
        geary # email reader
        evince # document viewer
        totem # video player
        gnome-calculator
        gnome-calendar
        gnome-music
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
        gnome-maps
        gnome-contacts
        gnome-clocks
        gnome-weather
      ]
    );
  };
}
