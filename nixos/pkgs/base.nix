{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    htop
    unzip
    inetutils
    hyfetch # yeah this is a basic package you will always need
    psmisc
    lm_sensors
  ];
}
