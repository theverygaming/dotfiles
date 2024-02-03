{ config, pkgs, ... }:

{
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = (with pkgs; [ gnome-tour gnome-photos ])
    ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    gnome-terminal
    epiphany # web browser
    geary # email reader
    evince # document viewer
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    gnome-maps
    gnome-contacts
    gnome-clocks
    gnome-weather
    gnome-calculator
    gnome-calendar
  ]);

  environment.systemPackages = with pkgs; [
    # gnome.gnome-boxes # gnome VNC etc. tool

    # xfce.xfce4-terminal
  ];
}
