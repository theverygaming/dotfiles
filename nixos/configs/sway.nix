{ config, pkgs, ... }:

{
  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;

  services.xserver = {
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      xfce.xfce4-terminal
      wofi # dmenu kinda thing
    ];
  };
}
