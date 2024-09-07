# TODO: -> NUR?? after figuring out how to pin ebnaut & ebsynth versions
{ config, pkgs, ... }:

{
  environment.systemPackages =
    let
      vlfrx_tools = with pkgs;
        stdenv.mkDerivation rec {
          pname = "vlfrx-tools";
          version = "0.9p";

          src = fetchurl {
            url = "http://abelian.org/vlfrx-tools/vlfrx-tools-${version}.tgz";
            sha256 = "sha256-tq9k1tnP6bmkqOdY1OkXqzvowRkEu71OC9D/vLPyjtc=";
          };

          buildInputs = [
            ncurses
            libshout
            flac
            libsamplerate
            fftw
            libpng
          ];
          configureFlags = [
            # required xforms which is not in nixpkgs and i did not feel like packaging it after a failed attempt
            "--without-x11"
          ];
        };
      ebnaut = with pkgs;
        stdenv.mkDerivation rec {
          pname = "ebnaut";
          version = "1.1";

          src = fetchurl {
            url = "http://abelian.org/ebnaut/ebnaut.c";
            sha256 = "sha256-ZPV2bdQ2O+IDx9q3oVOpx8150EK6IvwRa3n0xREYS4s=";
          };

          unpackPhase = ''
            cp $src ebnaut.c
          '';

          buildPhase = ''
            mkdir -p "$out"/bin
            gcc -std=gnu99 -Wall -O3 -o "$out"/bin/ebnaut ebnaut.c -lm -lpthread
          '';
        };
      ebsynth = with pkgs;
        stdenv.mkDerivation rec {
          pname = "ebsynth";
          version = "0.8h";

          src = fetchurl {
            url = "http://abelian.org/ebnaut/ebsynth.c";
            sha256 = "sha256-CnR6Apj4QCFkKhEL1IlX1KEINOB1dfoT53SAiTOWKmc=";
          };

          unpackPhase = ''
            cp $src ebsynth.c
          '';

          buildPhase = ''
            mkdir -p "$out"/bin
            gcc -std=gnu99 -Wall -O3 -o "$out"/bin/ebsynth ebsynth.c -lasound -lncurses -lfftw3 -lm -lpthread
          '';

          buildInputs = [
            alsa-lib
            ncurses
            fftw
          ];
        };
    in
    [
      vlfrx_tools
      pkgs.gnuplot # for plotting output from vlfrx-tools
      ebnaut
      ebsynth
    ];
}
