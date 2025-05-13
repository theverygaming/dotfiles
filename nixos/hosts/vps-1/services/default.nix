{ ... }:

{
  imports = [
    ./dns.nix
    ./website.nix
    ./monitoring.nix
    ./ca.nix
  ];
}
