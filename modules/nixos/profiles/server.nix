{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}:

let
  cfg = config.custom.profiles.server;
in
{
  options.custom.profiles.server = {
    enable = lib.mkEnableOption "Enable Server profile";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.discord_notif_webhook_url = {
      sopsFile = flakeInputs.secrets + "/common/notifications.yaml";
    };
    custom = {
      profiles.base.enable = lib.mkDefault true;

      pkggroups = {
        containerization.enable = lib.mkDefault true;
        containerization.rootless = lib.mkDefault false;
      };

      flake_auto_upgrade.enable = true;

      systemd_discord_notif.enable = true;
      systemd_discord_notif.webhookURLFile = config.sops.secrets.discord_notif_webhook_url.path;
    };

    nix.optimise.automatic = true;
    nix.optimise.dates = [ "03:00" ];

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
