{ config, pkgs, ... }:

{
  environment.systemPackages = let
    fox32asm = with pkgs;
      rustPlatform.buildRustPackage rec {
        pname = "fox32asm";
        version = "0.3.0";

        src = fetchgit {
          url = "https://github.com/fox32-arch/fox32asm.git";
          leaveDotGit = true; # for vergen
          rev = "bedf8d54c4e5d419b62532e392c5fc0954e82823";
          sha256 = "sha256-Snv1lcoqZUjIexjmtGwA0nV1YTxYdK2K1l7gmoXzhN0=";
        };

        cargoSha256 = "sha256-9bc9YTH4mc3xab44IP5Gh9/8WvP4HTRmEQUzUUcXgSo=";
      };
  in [ fox32asm ];
}
