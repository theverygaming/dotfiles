{ config, pkgs, ... }:

{
  imports = [
    ./custom/custom.nix
    ./desktop.nix
    ./base.nix
    ./social.nix
    ./dev.nix
    ./browsers.nix
    ./gaming.nix
    ./media.nix
    ./misc.nix
    ./webserver.nix
  ];
}
