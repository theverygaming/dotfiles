{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.custom.monitoring;
in
{
  options.custom.monitoring = {
    enable = lib.mkEnableOption "Enable monitoring";
    promScrapeTargets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        additional prometheus scrape targets
      '';
    };
    # TODO: do this properly lol
    promScrapeTargets5s = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        additional prometheus scrape targets (5s scrape interval)
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        listenAddress = "127.0.0.1";
        port = 9002;
      };
      smartctl = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9003;
      };
    };

    # FIXME: there should be a better way for identifying metrics per-host than the job
    services.opentelemetry-collector = {
      enable = true;
      package = pkgs.opentelemetry-collector-contrib;
      settings = {
        receivers.prometheus.config.scrape_configs = [
          {
            job_name = config.networking.hostName;
            scrape_interval = "15s";
            static_configs = [
              {
                targets = [
                  # node
                  "${config.services.prometheus.exporters.node.listenAddress}:${builtins.toString config.services.prometheus.exporters.node.port}"
                  # smartctl
                  "${config.services.prometheus.exporters.smartctl.listenAddress}:${builtins.toString config.services.prometheus.exporters.smartctl.port}"
                ] ++ cfg.promScrapeTargets;
              }
            ];
          }
          {
            job_name = config.networking.hostName + "_5s";
            scrape_interval = "5s";
            static_configs = [
              {
                targets = cfg.promScrapeTargets5s;
              }
            ];
          }
        ];

        exporters = {
          prometheusremotewrite = {
            endpoint = "http://10.13.12.1:9090/api/v1/write";
            # we want to keep collecting data even when we lose our internet connection!
            wal = {
              directory = "./prom_wal";
              buffer_size = 300;
              truncate_frequency = "1m";
            };
            resource_to_telemetry_conversion.enabled = true;
          };
        };

        service = {
          pipelines.metrics = {
            receivers = [ "prometheus" ];
            processors = [ ];
            exporters = [
              "prometheusremotewrite"
            ];
          };
          # telemetry.logs.level = "debug";
        };
      };
    };
  };
}
