{ config, pkgs, ... }:

{
  imports = [
    ./sound.nix
    ./hardware-configuration.nix # hardware scan results

    ../../common
    ../../users
  ];

  custom.profiles.desktop.enable = true;
  custom.desktop.sway = {
    enable = true;
  };

  deployment = {
    targetHost = "192.168.178.40";
    targetPort = 2222;
    targetUser = "root";
  };

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = false; # doesn't work on the mac
      efiSysMountPoint = "/boot/efi";
    };
    systemd-boot.enable = true;
  };

  # Networking
  networking.hostName = "macintosh";
  networking.networkmanager.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # we do not want xterm
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Enable touchpad support
  services.libinput.enable = true;

  # To be sorted in seperate file lmao

  environment.variables = {
    SUDO_PROMPT = "enter your password to the :3 organisation -> ";
    EDITOR = "nano";
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = true;
  };

  system.stateVersion = "25.05";
}
