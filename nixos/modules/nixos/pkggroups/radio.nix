{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.pkggroups.radio;
in
{
  options.custom.pkggroups.radio = {
    enable = lib.mkEnableOption "Enable Radio-related packages";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sdrpp
      zenity # required by SDR++ for file dialogs

      # FIXME: is packaged now, gotta wait a bit for it to arrive on unstable
      # custom.satdump

      custom.vlfrx-tools
      gnuplot # for plotting output from vlfrx-tools
      custom.ebnaut
      custom.ebsynth
    ];

    hardware.rtl-sdr.enable = lib.mkDefault true;
  };
}
