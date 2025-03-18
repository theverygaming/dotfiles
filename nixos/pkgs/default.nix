{ config, pkgs, ... }:

{
  imports = [
    ./custom
    ./misc.nix
    ./webserver.nix
    ./k8s.nix
  ];
}
