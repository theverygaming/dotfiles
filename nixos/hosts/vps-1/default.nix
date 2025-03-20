{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ../../common
    ../../users
  ];

  custom.profiles.base.enable = true;

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

  # TODO: ssh module // server profile
  # TODO: fail2ban maybe?
  services.openssh = {
    enable = true;
    ports = [
      2222
    ];
    settings.PasswordAuthentication = false; # aw hell nah
  };
}
