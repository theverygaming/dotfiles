{ flakeInputs, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ../../common
    ../../users
    ../../configs/wireguard_mesh.nix
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

  # Website
  services.caddy = {
    enable = true;
    virtualHosts = {
      "http://".extraConfig = ''
        header Content-Type text/html
        respond <<HTML
            <!DOCTYPE html>
            <html>
              <!-- :3 -->
              <head>
                <title>:3</title>
                <meta http-equiv="Refresh" content="5; URL=https://www.youtube-nocookie.com/embed/75KlCpeLo64?si=EgII1K2HQxFhbQUH" />
                <style>
                h1 {
                  margin: 0;
                  padding: 0;
                  white-space: nowrap;
                  font-family: monospace;
                  font-size: calc(100vw / .625 / 9);
                }
                </style>
              </head>
              <body>
                <h1>:3</h1>
              </body>
            </html>
        HTML 200
      '';
    };
  };
}
