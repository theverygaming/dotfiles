{ ... }:

{
  imports = [
    ./profiles
    ./pkggroups
    ./gnome.nix
    ./public_webserver.nix
    ./flake_autoupgrade.nix
    ./wg_mesh.nix
    ./monitoring.nix
    ./microvm.nix
    ./sway.nix
  ];
}
