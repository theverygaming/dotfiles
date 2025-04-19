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
    targetHost = "theverygaming.furrypri.de";
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

  sops.defaultSopsFile = flakeInputs.secrets + "/empty.yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Networking
  networking.hostName = "vps-1";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [
    53 # DNS
    80 # HTTP
    443 # HTTPS
  ];
  networking.firewall.allowedUDPPorts = [
    53 # DNS
  ];

  # DNS
  services.nsd = {
    enable = true;
    interfaces = [
      "0.0.0.0"
      "::"
    ];
    zones =
      let
        getZone = (import ../../dns.nix { inherit flakeInputs; }).getZone;
      in
      {
        "m.furrypri.de" = {
          data = flakeInputs.dns.lib.toString "m.furrypri.de" (getZone "m.furrypri.de");
        };
        "theverygaming.furrypri.de" = {
          data = flakeInputs.dns.lib.toString "theverygaming.furrypri.de" (
            getZone "theverygaming.furrypri.de"
          );
        };
        "test.furrypri.de" = {
          data = flakeInputs.dns.lib.toString "test.furrypri.de" (getZone "test.furrypri.de");
        };
      };
  };

  # Website
  services.anubis.instances."website" = {
    settings = {
      TARGET = "http://127.0.0.1:40001";
      BIND_NETWORK = "tcp";
      BIND = "127.0.0.1:40000";
      SERVE_ROBOTS_TXT = true;
    };
  };
  services.caddy = {
    enable = true;
    virtualHosts =
      let
        website_built = pkgs.stdenv.mkDerivation rec {
          pname = "website-built";
          version = "7f2fa0e4b9ca11b39f1fe1f79bda5cc06c03095d";

          src = pkgs.fetchFromGitHub {
            owner = "theverygaming";
            repo = "website";
            rev = version;
            sha256 = "sha256-kXrIwj3Iwlic9ZgpcIEe3r1WAu6fHAy/4dVcm7OJgQM=";
          };

          nativeBuildInputs = [
            pkgs.jekyll
            pkgs.rubyPackages.jekyll-feed
          ];

          buildPhase = ''
            jekyll build
          '';

          installPhase = ''
            cp -r _site $out
          '';
        };
        # the nix store forces dates to be on the epoch which terribly breaks Caddys Last-Modified header.
        # So we use ETag based on the store path instead
        caddy_etag_hack = ''
          header {
              ETag "${builtins.hashString "sha256" (builtins.baseNameOf website_built)}"
              -Last-Modified
          }
        '';
      in
      {
        "m.furrypri.de".extraConfig = ''
          redir https://theverygaming.furrypri.de
        '';

        "http://theverygaming.furrypri.de:40001".extraConfig = ''
          bind 127.0.0.1
          root * ${website_built}
          ${caddy_etag_hack}
          file_server
          handle_errors {
              @404 {
                  expression {http.error.status_code} == 404
              }
              rewrite @404 /err/404.html
              file_server
              ${caddy_etag_hack}
          }
        '';

        "theverygaming.furrypri.de".extraConfig = ''
          encode gzip
          reverse_proxy http://127.0.0.1:40000
        '';

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
