{ flakeInputs, pkgs, ... }:

{
  imports = [
    ./odoo.nix
    ./reverseproxy.nix
  ];
}
