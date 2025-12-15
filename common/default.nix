{
  config,
  flakeInputs,
  pkgs,
  ...
}:

{
  imports = [
    ./home-manager.nix
  ];

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

  # I NEED ALL OF THE GIGABYTES (this optimises the store on each build)
  nix.settings.auto-optimise-store = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # FIXME: this is a.. bad place
  system.stateVersion = "25.05";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # tmpfs :3
  fileSystems."/tmp" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=8G"
      "mode=755"
    ];
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

  security.pki.certificateFiles = [
    "${pkgs.writeText "custom_ca_root.crt" ''
      -----BEGIN CERTIFICATE-----
      MIIBjDCCATKgAwIBAgIRAIrIXrNg6iv7fMPaZWa8YI4wCgYIKoZIzj0EAwIwJDEM
      MAoGA1UEChMDdXd1MRQwEgYDVQQDEwt1d3UgUm9vdCBDQTAeFw0yNTA1MTMxOTIy
      MzJaFw0zNTA1MTExOTIyMzJaMCQxDDAKBgNVBAoTA3V3dTEUMBIGA1UEAxMLdXd1
      IFJvb3QgQ0EwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQO00kuubBlg3tIUYZT
      gZY81dty01zM/k/wkHXS6oLz13kaKWZqzdFAfqm7KHz7A8oQXfbwQBQjrg1BS6Lr
      NLDCo0UwQzAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBATAdBgNV
      HQ4EFgQUNdvO5aYqgKAW/rX1SKntAZmZqs4wCgYIKoZIzj0EAwIDSAAwRQIgAjfg
      RVAzzrtG1ZoS5u97DlGKCHlzYTP5+ay1NOxneswCIQDxs7mDc+7umJ/nOBMiAiI9
      cSUW5KcgaacjuytC5X3Ddw==
      -----END CERTIFICATE-----
    ''}"
  ];

  nix.settings.download-buffer-size = 4096 * 1024 * 1024;
}
