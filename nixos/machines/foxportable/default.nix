{ config, pkgs, ... }:

{
  imports = [
    ./sound.nix
    ./users.nix
    ./hardware-configuration.nix # hardware scan results
  ];

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    systemd-boot.enable = true;
  };

  # Networking
  networking.hostName = "foxportable";
  networking.networkmanager.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # we do not want xterm
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Enable touchpad support
  services.xserver.libinput.enable = true;

  # To be sorted in seperate file lmao

  environment.variables = {
    SUDO_PROMPT = "enter your password to the :3 organisation -> ";
    EDITOR = "nano";
  };

  programs.zsh = {
    enable = true;
    interactiveShellInit = "alias neofetch=hyfetch";
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "colored-man-pages" ];
      theme = "lambda";
      customPkgs = with pkgs; [ nix-zsh-completions ];
    };
  };
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = true;
  };
  environment.shells = with pkgs; [ zsh ];
}
