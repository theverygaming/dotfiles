{ flakeInputs, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    80 # HTTP
    443 # HTTPS
  ];

  services.anubis.instances."website" = {
    settings = {
      TARGET = "http://127.0.0.1:40001";
      BIND_NETWORK = "tcp";
      BIND = "127.0.0.1:40000";
      SERVE_ROBOTS_TXT = true;
      METRICS_BIND_NETWORK = "tcp";
      METRICS_BIND = "127.0.0.1:9100";
    };
  };

  services.caddy = {
    enable = true;
    globalConfig = ''
      metrics
    '';
    virtualHosts =
      let
        website_built = pkgs.stdenv.mkDerivation rec {
          pname = "website-built";
          version = "0e22012ff1755a2f35797ef9e8f94b7f1073b0f7";

          src = pkgs.fetchFromGitHub {
            owner = "theverygaming";
            repo = "website";
            rev = version;
            sha256 = "sha256-JwBuvMn1plVq83IyD5BCbVkG1n0Aph/d2e9UUclTPIM=";
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

  custom.monitoring.promScrapeTargets = [
    # Caddy
    "127.0.0.1:2019"
    # Anubis
    "127.0.0.1:9100"
  ];
}
