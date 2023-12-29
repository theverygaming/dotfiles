{ config, pkgs, ... }:

{
  imports = [
    ./custom
    ./desktop.nix
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
