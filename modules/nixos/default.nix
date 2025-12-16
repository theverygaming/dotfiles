{ ... }:

{
  imports = [
    ./profiles
    ./pkggroups
    ./public_webserver.nix
    ./flake_autoupgrade.nix
    ./wg_mesh.nix
    ./monitoring.nix
    ./microvm.nix
    ./sway.nix
    ./systemd_discord_notif.nix
  ];
}
