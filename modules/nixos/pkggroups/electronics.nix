{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.pkggroups.electronics;
in
{
  options.custom.pkggroups.electronics = {
    enable = lib.mkEnableOption "Enable Electronics-related packages";
  };

  config = lib.mkIf cfg.enable {
    # logic analyzer stuff
    programs.pulseview.enable = true;

    environment.systemPackages = with pkgs; [
      # convenient serial IO tool
      tio
    ];
  };
}
