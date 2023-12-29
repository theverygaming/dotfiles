{ config, pkgs, ... }:

{
  imports = [
    ./pkgs
    ./nvidia.nix
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
    grub = {
      efiSupport = true;
      device = "nodev";
    };
  };

  # Kernel config
  boot.kernel.sysctl = { "vm.swappiness" = 1; };

  # Networking
  networking.hostName = "foxnix";
  networking.networkmanager.enable = true;

  # Locale stuff
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "de";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # I NEED ALL OF THE GIGABYTES
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # we do not want xterm
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support
  services.xserver.libinput.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "unstable";

  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "weekly";

  # To be sorted in seperate file lmao

  nix.settings.experimental-features = [ "nix-command" ];

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
    pinentryFlavor = "curses";
    enableSSHSupport = true;
  };
  environment.shells = with pkgs; [ zsh ];

  # tmpfs :3
  fileSystems."/tmp" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=8G" "mode=755" ];
  };
}
