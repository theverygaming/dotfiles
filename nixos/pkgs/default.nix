{ pkgs, ... }:

{
  satdump = pkgs.callPackage ./satdump { };
  vlfrx-tools = pkgs.callPackage ./vlfrx-tools { };
  ebnaut = pkgs.callPackage ./ebnaut { };
  ebsynth = pkgs.callPackage ./ebsynth { };
  minivmac = pkgs.callPackage ./minivmac { };
  fox32asm = pkgs.callPackage ./fox32asm { };
}
