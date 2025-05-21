{
  flakeInputs,
  lib,
  config,
  ...
}:

{
  custom.microvm = {
    enable = true;
    vms = {
      "odoo" = {
        id = "1";
        ip = "10.69.0.2";
        insecureDebug = true;
        modules = [
          (
            { pkgs, ... }:
            {
              system.stateVersion = "25.05";
              microvm = {
                mem = 2048;
                vcpu = 2;

                volumes = [
                  {
                    fsType = "ext4";
                    label = "persistent";
                    mountPoint = "/persistent";
                    size = 15000; # M
                    image = "./persistent.img";
                    autoCreate = true;
                  }
                ];
              };
              systemd.services.create_pg_data_dir = {
                description = "Create PostgreSQL data directory";
                wantedBy = [ "postgresql.service" ];
                before = [ "postgresql.service" ];
                script = ''
                  mkdir -p "/persistent/pg_data/${config.services.postgresql.package.psqlSchema}"
                  chown postgres:postgres "/persistent/pg_data/${config.services.postgresql.package.psqlSchema}"
                '';
                serviceConfig = {
                  Type = "oneshot";
                  RemainAfterExit = true;
                };
              };
              services.postgresql.dataDir = "/persistent/pg_data/${config.services.postgresql.package.psqlSchema}";
              systemd.services.create_odoo_data_dir = {
                description = "Create Odoo data directory";
                wantedBy = [ "odoo.service" ];
                before = [ "odoo.service" ];
                script = ''
                  mkdir -p "/persistent/odoo_data"
                  chown odoo:odoo "/persistent/odoo_data"
                '';
                serviceConfig = {
                  Type = "oneshot";
                  RemainAfterExit = true;
                };
              };
              services.odoo = {
                enable = true;
                package = pkgs.odoo.overrideAttrs (old: rec {
                  patches = [
                    # TODO: file an issue with the worker thing in NixOS
                    ./odoo.patch
                  ];
                });
                settings.options = {
                  workers = 2;
                  limit_time_cpu = 600;
                  limit_time_real = 1200;
                  database = "odoo";
                  list_db = false;
                  # we do not use the database manager, the admin password is set - just in case it happens to enable itself _somehow_
                  # In that case, this is a random generated hash that should be rather hard to crack, hopefully :sob:
                  # (and i have not written down the actual password behind this hash anywhere)
                  admin_passwd = "$pbkdf2-sha512$600000$rTVGyLn3vheilJJyLsXY.w$zdPq7GQVXqRiG0cg1k.qJut1Pzj3djwWcUoZpHkzW3dg1XChca.uR7YdjOAZsGGYkw6fNvXOAyT6Dr9.Q0NoQw";
                  # this is stupid and i don't like it.
                  # Unfortunately the Odoo module does not use mkDefault :(
                  # TODO: create a gh issue and complain
                  proxy_mode = lib.mkForce true;
                  data_dir = lib.mkForce "/persistent/odoo_data";
                };
                autoInit = true;
                autoInitExtraFlags = [ "--without-demo=all" ];
              };
              systemd.services.odoo = {
                serviceConfig.TimeoutStartSec = "20min"; # Odoo can take a while to initialize, esp under high system load
                serviceConfig.Restart = "on-failure";
                # otherwise Odoo cannot read the persistent path
                serviceConfig.ReadWritePaths = [ "/persistent/odoo_data" ];
              };
              networking.firewall.allowedTCPPorts = [
                8069
                8072
              ];
            }
          )
        ];
      };
    };
  };
}
