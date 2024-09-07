{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ spotify vlc jellyfin-media-player ];
  networking.firewall.allowedTCPPorts = [ 57621 ];
}
