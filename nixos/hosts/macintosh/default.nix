{ config, pkgs, ... }:

{
  imports = [
    ./sound.nix
    ./hardware-configuration.nix # hardware scan results

    ../../common
    ../../pkgs
    ../../configs/i3.nix
    ../../users/user
  ];

  custom.profiles.desktop.enable = true;

  nixpkgs.system = "x86_64-linux";

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
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

  hardware.rtl-sdr.enable = true;
}
