{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    obs-studio
    libsForQt5.kdenlive
    audacity
    #texlive.combined.scheme-full
    #perlPackages.YAMLTiny # to make latexindent work
    sdrpp
    zenity # required by SDR++ for file dialogs
  ];
}
