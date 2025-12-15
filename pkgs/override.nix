{ ... }:

{
  nixpkgs.config.packageOverrides = pkgs: {
    custom = import (./default.nix) {
      inherit pkgs;
    };
  };
}
