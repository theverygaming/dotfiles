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
          rev = "4332cc72cc4d6e47efa34acc8c8bccb900add4e9";
          hash = "sha256-0cRKd3YOBQw6ZWzxE1bBwDfDm7w2hfuxhIg8M6e4gI0=";
        };
        # master doesn't need the patch anymore
        postPatch = "";

        # verywip dependency
        buildInputs = old.buildInputs ++ [
          pkgs.dbus
        ];
      }))

      nur_theverygaming.vlfrx-tools
      gnuplot # for plotting output from vlfrx-tools
      nur_theverygaming.ebnaut
      nur_theverygaming.ebsynth
    ];

    hardware.rtl-sdr.enable = lib.mkDefault true;
  };
}
