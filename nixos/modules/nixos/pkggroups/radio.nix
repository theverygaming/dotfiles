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

      satdump

      nur_theverygaming.vlfrx-tools
      gnuplot # for plotting output from vlfrx-tools
      nur_theverygaming.ebnaut
      nur_theverygaming.ebsynth
    ];

    hardware.rtl-sdr.enable = lib.mkDefault true;
  };
}
