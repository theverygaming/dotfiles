{ flakeInputs, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ../../common
    ../../users
    ../../configs/wireguard_mesh.nix
    ./services
  ];

  custom.profiles.server.enable = true;

  deployment = {
    targetHost = "amdE350.local.infra.theverygaming.furrypri.de";
    targetPort = 2222;
    targetUser = "root";
  };

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      enable = true;
      device = "/dev/sda";
      efiSupport = true;
    };
  };

  sops.defaultSopsFile = flakeInputs.secrets + "/empty.yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Networking
  networking.hostName = "amdE350";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [
    80 # HTTP
    443 # HTTPS
  ];

  custom.wg_mesh.firewall.allowedTCPPorts = [
    9091 # FIXME: grafana (debugging)
  ];

  services.grafana = {
    enable = true;
    #domain = "grafana.pele";
    settings.server = {
      http_port = 9091;
      http_addr = "10.13.12.4";
    };
  };

  custom.monitoring.promScrapeTargets5s = [
    # smart meter
    "192.168.178.40:80"
  ];
}
