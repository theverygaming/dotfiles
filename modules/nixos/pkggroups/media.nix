{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.pkggroups.media;
in
{
  options.custom.pkggroups.media = {
    enable = lib.mkEnableOption "Enable Media packages";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      spotify # no spotifyd because apparently that requires premium
      vlc
      # jellyfin-media-player # depends on qtwebengine-5.15.19 which is marked insecure... -> removed for now
    ];
    networking.firewall.allowedTCPPorts = [
      57621 # Spotify: Allow syncing play state to mobile devices in the same network
    ];
    networking.firewall.allowedUDPPorts = [
      5353 # Spotify: Allow discovery of Google Cast devices and other "Spotify Connect devices"
    ];
  };
}
