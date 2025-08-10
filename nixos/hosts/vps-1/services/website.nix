{ flakeInputs, pkgs, ... }:

{
  imports = [
    flakeInputs.nixocaine.nixosModules.default
  ];

  networking.firewall.allowedTCPPorts = [
    80 # HTTP
    443 # HTTPS
  ];

  services.iocaine.servers."website" = {
    enable = true;
    config = {
      server.bind = "127.0.0.1:40000";
      server.request-handler = {
        language = "roto";
        path = pkgs.writeTextFile {
          name = "pkg.roto";
          text = ''
            function init() -> Verdict [Unit, String] {
              let robot_list = Json
                .load_file("${flakeInputs.ai-robots-txt + "/robots.json"}")
                .get_keys();
              iocaine_patterns.insert_patterns("ai.robots.txt", robot_list);

              accept
            }

            function decide(request: Request) -> Verdict[Outcome, Outcome] {
              let robot_patterns = iocaine_patterns.get("ai.robots.txt");
              if robot_patterns.is_match(request.header("user-agent")) {
                metrics.inc("rule::ai.robots.txt");
                accept Outcome.garbage()
              }
              metrics.inc("rule::default");
              reject Outcome.not_for_us();
            }
          '';
          destination = "/pkg.roto";
        };
      };
      # https://github.com/ai-robots-txt/ai.robots.txt/raw/refs/heads/main/robots.json
      sources = {
        words = pkgs.fetchurl {
          url = "https://cgit.git.savannah.gnu.org/cgit/miscfiles.git/plain/web2";
          hash = "sha256-KSmJWrP+x4xpY+vly7NJP+T8nhHroJWlInh7ivxTqGM=";
        };
        markov = [
          (pkgs.fetchurl {
            url = "https://archive.org/download/GeorgeOrwells1984/1984_djvu.txt";
            hash = "sha256-9R1PTa8yDtkfH+4rU5BF62ee73irhd3VYX1QB5KU+ZU=";
          })
          (pkgs.fetchurl {
            url = "https://archive.org/download/ost-english-brave_new_world_aldous_huxley/Brave_New_World_Aldous_Huxley_djvu.txt";
            hash = "sha256-6WkaO/3zQIezGzJDp4QjglikiTZTxgo0P4MEff2mdcY=";
          })
        ];
      };
      metrics = {
        enable = true;
        bind = "127.0.0.1:9100";
      };
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
        "(iocaine)".extraConfig = ''
          @read method GET HEAD
          @not-read not {
            method GET HEAD
          }
          reverse_proxy @read http://127.0.0.1:40000 {
            @fallback status 421
            handle_response @fallback {
              {blocks.handler}
            }
          }
          handle @not-read {
            {blocks.default}
          }
        '';
        "m.furrypri.de".extraConfig = ''
          redir https://theverygaming.furrypri.de
        '';

        # did it like this because I couldn't get the damn
        # handle_errors directive to work in the `import iocane` block
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
          import iocaine {
            handler {
              reverse_proxy http://127.0.0.1:40001
            }
            default {
              respond 405
            }
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

  custom.monitoring.promScrapeTargets = [
    # Caddy
    "127.0.0.1:2019"
    # iocaine
    "127.0.0.1:9100"
  ];
}
