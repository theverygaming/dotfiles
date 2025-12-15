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

      (pkgs.satdump.overrideAttrs (old: {
        src = fetchFromGitHub {
          owner = "SatDump";
          repo = "SatDump";
          rev = "943de7df03405a53753febf602361e73868dc13e";
          hash = "sha256-17ZtwTK3VOPRc+sy8A+ZmY88j862FvuKARwIifHaLgQ=";
        };
        postPatch = "";
      }))

      nur_theverygaming.vlfrx-tools
      gnuplot # for plotting output from vlfrx-tools
      nur_theverygaming.ebnaut
      nur_theverygaming.ebsynth
    ];

    hardware.rtl-sdr.enable = lib.mkDefault true;
  };
}
