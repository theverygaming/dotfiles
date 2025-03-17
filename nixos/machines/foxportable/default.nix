{ config, pkgs, ... }:

{
  imports = [
    ./sound.nix
    ./hardware-configuration.nix # hardware scan results

    ../../common
    ../../pkgs
    ../../configs/gnome.nix
    ../../users/user
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
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable touchpad support
  services.libinput.enable = true;

  # To be sorted in seperate file lmao

  environment.variables = {
    SUDO_PROMPT = "enter your password to the :3 organisation -> ";
    EDITOR = "nano";
  };

  # for zsh
  # adds itself to ohMyZsh Plugins if ohMyZsh is enabled
  programs.fzf.fuzzyCompletion = true;
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

  hardware.rtl-sdr.enable = true;

  # this is a thinkpad meow!!
  # https://www.reddit.com/r/NixOS/comments/1d1v6ev/comment/l603nyi
  powerManagement.powertop.enable = true; # enable powertop auto tuning on startup.

  services.system76-scheduler.settings.cfsProfiles.enable = true; # Better scheduling for CPU cycles - thanks System76!!!
  services.thermald.enable = true; # Enable thermald, the temperature management daemon. (only necessary if on Intel CPUs)
  services.power-profiles-daemon.enable = false; # Disable GNOMEs power management
  services.tlp = {
    # Enable TLP (better than gnomes internal power manager)
    enable = true;
    settings = {
      # sudo tlp-stat or tlp-stat -s or sudo tlp-stat -p
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      START_CHARGE_THRESH_BAT0 = 70;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
}
