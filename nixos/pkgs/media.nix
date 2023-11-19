{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ spotify vlc ];
  networking.firewall.allowedTCPPorts = [ 57621 ];
}
