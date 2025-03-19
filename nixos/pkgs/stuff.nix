{ config, pkgs, ... }:

{
  imports = [
    ./custom
    ./webserver.nix
  ];
}
