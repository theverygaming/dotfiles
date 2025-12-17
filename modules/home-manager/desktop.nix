{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.desktop;
in
{
  options.custom.desktop = {
    background = lib.mkOption {
      default = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/KDE/plasma-workspace-wallpapers/881363e7ee5ec0d7790c5ae73c49d09287a9a0de/ScarletTree/contents/images_dark/5120x2880.png";
        hash = "sha256-I9jf+6gcOH4oychznKAZMqMWYMKvkWgfkjtZw0J9QSo=";
      };
      type = lib.types.package;
      description = ''
        Desktop background image (image file)
      '';
    };
  };

  config = { };
}
