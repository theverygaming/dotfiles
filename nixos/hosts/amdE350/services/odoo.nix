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
      "odoo-private" = {
        id = "1";
        ip = "10.69.0.2";
        insecureDebug = true;
        host_share = true;
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
              fileSystems."/root" = {
                device = "/persistent/root";
                options = [ "bind" ];
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
                  # (this is needed in case the database manager activates, because otherwise it would
                  #  let the user set a password! And then anyone with access could download a full DB dump..)
                  admin_passwd = "$pbkdf2-sha512$600000$rTVGyLn3vheilJJyLsXY.w$zdPq7GQVXqRiG0cg1k.qJut1Pzj3djwWcUoZpHkzW3dg1XChca.uR7YdjOAZsGGYkw6fNvXOAyT6Dr9.Q0NoQw";
                  # this is stupid and i don't like it.
                  # Unfortunately the Odoo module does not use mkDefault :(
                  # TODO: create a gh issue and complain
                  proxy_mode = lib.mkForce true;
                  data_dir = lib.mkForce "/persistent/odoo_data";
                };
                autoInit = true;
                autoInitExtraFlags = [ "--without-demo=all" ];
                addons = [
                  (pkgs.fetchFromGitHub {
                    owner = "OCA";
                    repo = "bank-statement-import";
                    rev = "badd66db9b4061818ef47cd4c0c76cb0321a85bc";
                    sha256 = "sha256-DvLXgF65oB49jPjH0Qhy+nEjbNhoKJC+S0cYJSSBiqc=";
                  })
                  (pkgs.fetchFromGitHub {
                    owner = "OCA";
                    repo = "account-reconcile";
                    rev = "071e078a4cf50ae2451f91c23326b57c03716bd7";
                    sha256 = "sha256-nxy8tetb3yYxiI9px44+OgL4+i7kTODyj/zACtKsTjI=";
                  })
                  (pkgs.fetchFromGitHub {
                    owner = "OCA";
                    repo = "web";
                    rev = "1f8eb84f4dd571fff5e5805e7a5bdb5e3df1cd13";
                    sha256 = "sha256-5JIIhYJ/NJtClvNyFuBEapN6EWLn9AV710Qdi+WoQj0=";
                  })
                  (pkgs.fetchFromGitHub {
                    owner = "OCA";
                    repo = "project";
                    rev = "3f4b1865a7a156110eaf9433d896df4279f05e92";
                    sha256 = "sha256-iWLB/IVXqu9k9QchsnTV/oknzx+LcsDR3YX8QAohgRs=";
                  })
                ];
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
              systemd.services.odoo-backup = {
                description = "Run full Odoo Backup";
                after = [ "postgresql.service" ];
                requires = [ "postgresql.service" ];
                script = ''
                  mkdir -p /host_share/odoo-backup
                  ${pkgs.rsync}/bin/rsync -avz --no-owner --no-group --delete /persistent/odoo_data/ /host_share/odoo-backup/data
                  ${pkgs.su}/bin/su postgres -c '${pkgs.postgresql}/bin/pg_dump --no-owner -d odoo' > /host_share/odoo-backup/db.sql
                '';
                serviceConfig = {
                  Type = "oneshot";
                };
              };
              systemd.timers.odoo-backup = {
                wantedBy = [ "timers.target" ];
                timerConfig = {
                  OnCalendar = [
                    "23:00"
                    "05:00"
                    "11:00"
                    "17:00"
                  ];
                  Persistent = true;
                };
              };
            }
          )
        ];
      };
    };
  };
}
