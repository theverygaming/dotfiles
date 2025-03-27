{ flakeInputs, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ../../common
    ../../users
  ];

  custom.profiles.server.enable = true;

  deployment = {
    # also vps-1.infra.test.furrypri.de but the DNS for
    # test.furrypri.de runs there and is a bit unreliable
    # for the time being sooo lets use something else for now
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
    zones = {
      "test.furrypri.de" = {
        data = flakeInputs.dns.lib.toString "test.furrypri.de" (with flakeInputs.dns.lib.combinators; {
          TTL = 300;
          SOA = {
            #nameServer = "ns1"; # TODO: ns1.test.furrypri.de should be a thing! :3
            nameServer = "theverygaming.furrypri.de.";
            adminEmail = "dnsadmin@theverygaming.furrypri.de";
            serial = 2025032100; # The recommended syntax is YYYYMMDDnn (YYYY=year, MM=month, DD=day, nn=revision number
            refresh = 60 * 60;
            retry = 60 * 30;
            expire = 60 * 60 * 24;
          };

          CAA = letsEncrypt "ssladmin@theverygaming.furrypri.de";

          subdomains = {
            "infra" = {
              subdomains = {
                "vps-1" = {
                  A = [
                    "159.69.26.5"
                  ];
                  # TODO: AAAA
                };
                "vps-old" = {
                  A = [
                    "128.140.1.26"
                  ];
                };
              };
            };
          };
        });
      };
    };
  };

  # Website
  # TODO: use https://github.com/TecharoHQ/anubis -- waiting for https://github.com/NixOS/nixpkgs/pull/392018
  services.caddy = {
    enable = true;
    virtualHosts = 
    let
      website_built = pkgs.stdenv.mkDerivation rec {
        pname = "website-built";
        version = "bc4449eeb402869bf7cce6f1228b6267e4964aaf";

        src = pkgs.fetchFromGitHub {
          owner = "theverygaming";
          repo = "website";
          rev = version;
          sha256 = "sha256-CnXtN/tOsk9iTQ2pP63degK7miv7GmhyCT8Fvz31gDo=";
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
    in {
      "m.furrypri.de".extraConfig = ''
        redir https://theverygaming.furrypri.de
      '';

      "http.m.furrypri.de".extraConfig = ''
        redir http://http.theverygaming.furrypri.de
      '';

      "http://http.theverygaming.furrypri.de".extraConfig = ''
        encode gzip
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
