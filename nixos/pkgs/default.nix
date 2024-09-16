{ config, pkgs, ... }:

{
  imports = [
    ./custom
    ./base.nix
    ./social.nix
    ./dev.nix
    ./browsers.nix
    ./gaming.nix
    ./media.nix
    ./misc.nix
    ./webserver.nix
    ./k8s.nix
  ];
}
