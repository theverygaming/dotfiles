{ config, pkgs, ... }:

{
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = (with pkgs; [
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
  ]) ++ (with pkgs.gnome; [
    gnome-music
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    gnome-maps
    gnome-contacts
    gnome-clocks
    gnome-weather
  ]);

  /*
    services.xserver.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
    oxygen # weird theme
    kate # code editor
    okular # Document viewer
    gwenview # image viewer
    elisa # music player
    ];
  */
}
