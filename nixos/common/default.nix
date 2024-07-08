{ config, ... }:

{
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

  # Configure console keymap
  console.keyMap = "us";

  # I NEED ALL OF THE GIGABYTES
  nix.settings.auto-optimise-store = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "unstable";

  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "weekly";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # tmpfs :3
  fileSystems."/tmp" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=8G" "mode=755" ];
  };

  virtualisation.vmVariant = {
    # for nixos-rebuild build-vm
    virtualisation = {
      memorySize = 3072;
      cores = 3;
      #qemu.options = [
      #  "-vga none -device qxl-vga,vgamem_mb=64,ram_size_mb=256,vram_size_mb=128,max_outputs=3"
      #  "-display none -spice port=5900,addr=127.0.0.1,disable-ticketing"
      #];
    };
  };
}
