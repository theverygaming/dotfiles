{ config, pkgs, ... }:

{
  imports = [ ./minivmac.nix ./fox32.nix ./satdump.nix ];
}
