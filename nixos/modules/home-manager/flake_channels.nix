{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}:

let
  cfg = config.custom.flake_channels;
in
{
  options.custom.flake_channels = {
    enable = lib.mkEnableOption "Use channels from flake";
  };

  config = lib.mkIf cfg.enable {
    nix = {
      channels = {
        nixpkgs = flakeInputs.nixpkgs;
      };
      keepOldNixPath = false;
    };
  };
}
