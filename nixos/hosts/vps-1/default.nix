{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ../../common
    ../../users
  ];

  custom.profiles.server.enable = true;

  deployment = {
    targetHost = "vps-1.infra.test.furrypri.de";
    targetPort = 2222;
    targetUser = "root";
  };

  boot.loader = {
    efi = {
      canTouchEfiVariables = false;
      efiSysMountPoint = "/boot/efi";
    };
    systemd-boot.enable = true;
  };

  # Networking
  networking.hostName = "vps-1";
  networking.networkmanager.enable = true;
}
