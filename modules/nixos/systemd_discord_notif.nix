{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}:

# strongly inspired by https://getchoo.com/blog/systemd-discord-notifier/ :3
let
  cfg = config.custom.systemd_discord_notif;
  serviceName = "discord-notif-service-failure";
in
{
  options.custom.systemd_discord_notif = {
    enable = lib.mkEnableOption "Enable discord notifications on systemd service failures";
    webhookURLFile = lib.mkOption {
      default = null;
      type = lib.types.path;
      description = ''
        Path to a file containing the discord webhook URL
      '';
    };
    message = lib.mkOption {
      type = lib.types.str;
      default = ''
        @everyone Service `%i` failed on `${config.networking.hostName}`
        flake commit: `${flakeInputs.self.rev or flakeInputs.self.dirtyRev or "unknown"}`
        flake modification date: <t:${builtins.toString (flakeInputs.self.lastModified or "unknown")}:f>
        flake outPath: `${flakeInputs.self.outPath}`
      '';
    };
    hookAllServices = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        if true will install the discord failure service into all systemd services with OnFailure
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services."${serviceName}@" = {
      description = "send a discord webhook notification on service failure";

      after = [ "network.target" ];

      path = [
        pkgs.curl
      ];

      script = ''
        curl -X POST --data-urlencode "content=$MESSAGE" "$(systemd-creds cat DISCORD_WEBHOOK_URL)"
      '';

      environment = {
        MESSAGE = cfg.message;
      };

      serviceConfig = {
        Type = "oneshot";
        LoadCredential = "DISCORD_WEBHOOK_URL:${cfg.webhookURLFile}";
      };
    };

    systemd.packages =
      if cfg.hookAllServices then
        [
          (pkgs.linkFarm "systemd-discord-notif-unit-overrides" {
            "lib/systemd/system/service.d/${serviceName}.conf" =
              (pkgs.formats.systemd { }).generate "${serviceName}.conf"
                {
                  Unit = {
                    OnFailure = [ "${serviceName}@%N.service" ];
                  };
                };

            "lib/systemd/system/${serviceName}@.service.d/${serviceName}.conf" = pkgs.emptyFile;
          })
        ]
      else
        [ ];
  };
}
