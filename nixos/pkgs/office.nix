{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libreoffice-qt6-fresh
    marp-cli # Markdown presentation tool
  ];
}
