# TOOD: -> NUR??
{ config, pkgs, ... }:

{
  environment.systemPackages = let
    minivmac = with pkgs;
      stdenv.mkDerivation rec {
        name = "minivmac-36.04";

        src = fetchFromGitHub {
          owner = "theverygaming";
          repo = "minivmac";
          rev = "b85c49537d013ba7e376be182ddebb731eb7729c";
          sha256 = "sha256-Kxztb55/gk66FO4GHIZEqRty/jhSnn43ztF3alMvQLc=";
        };

        buildInputs = [ xorg.libX11 alsa-lib ];

        configurePhase = ''
          $CC setup/tool.c -o setup_t
          ./setup_t -t lx64 -m Plus > setup.sh
          sed -i "s/ \/bin\/bash/\/bin\/sh/g" setup.sh
          sed -i "s/gcc/$CC/g" setup.sh
          cat setup.sh
          chmod +x setup.sh
          ./setup.sh
          sed -i "s/-lX11/& -lasound/" Makefile
        '';

        buildPhase = ''
          make -j$NIX_BUILD_CORES
        '';

        installPhase = ''
          mkdir -p "$out"/bin
          cp minivmac "$out"/bin/minivmacPlus
        '';
      };
  in [ minivmac ];
}
