{ flakeInputs, pkgs, ... }:

{
  imports = [
    ./dns.nix
    ./website.nix
    ./monitoring.nix
  ];
}
