{ config, pkgs, ... }:

{
  imports = [
    ./nvidia.nix
    ./sound.nix
    ./hardware-configuration.nix # hardware scan results
  ];

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      efiSupport = true;
      device = "nodev";
    };
  };

  # Kernel config
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.hostName = "foxnix";
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

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support
  services.libinput.enable = true;

  # To be sorted in seperate file lmao

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

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

  # avahi
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # i just want to build an rpi image...
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # TODO: move
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
