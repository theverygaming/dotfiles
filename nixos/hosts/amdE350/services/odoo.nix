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
                  /*
                    # TODO: report this skill issue:
                    RPC_ERROR

                    Odoo Server Error

                    Occured on <URL> on model account.journal and id 10 on 2025-06-16 18:29:29 GMT

                    Traceback (most recent call last):
                      File "/nix/store/khhxl07bvn0mjgfx5gjw90ayigpwqvan-odoo-18.0.20250506/lib/python3.12/site-packages/odoo/http.py", line 1963, in _transactioning
                        return service_model.retrying(func, env=self.env)
                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                      File "/nix/store/khhxl07bvn0mjgfx5gjw90ayigpwqvan-odoo-18.0.20250506/lib/python3.12/site-packages/odoo/service/model.py", line 156, in retrying
                        result = func()
                                ^^^^^^
                      File "/nix/store/khhxl07bvn0mjgfx5gjw90ayigpwqvan-odoo-18.0.20250506/lib/python3.12/site-packages/odoo/http.py", line 1930, in _serve_ir_http
                        response = self.dispatcher.dispatch(rule.endpoint, args)
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                      File "/nix/store/khhxl07bvn0mjgfx5gjw90ayigpwqvan-odoo-18.0.20250506/lib/python3.12/site-packages/odoo/http.py", line 2178, in dispatch
                        result = self.request.registry['ir.http']._dispatch(endpoint)
                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                      File "/nix/store/khhxl07bvn0mjgfx5gjw90ayigpwqvan-odoo-18.0.20250506/lib/python3.12/site-packages/odoo/addons/base/models/ir_http.py", line 333, in _dispatch
                        result = endpoint(**request.params)
                                ^^^^^^^^^^^^^^^^^^^^^^^^^^
                      File "/nix/store/khhxl07bvn0mjgfx5gjw90ayigpwqvan-odoo-18.0.20250506/lib/python3.12/site-packages/odoo/http.py", line 727, in route_wrapper
                        result = endpoint(self, *args, **params_ok)
                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                      File "/nix/store/khhxl07bvn0mjgfx5gjw90ayigpwqvan-odoo-18.0.20250506/lib/python3.12/site-packages/odoo/addons/web/controllers/dataset.py", line 36, in call_kw
                        return call_kw(request.env[model], method, args, kwargs)
                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                      File "/nix/store/khhxl07bvn0mjgfx5gjw90ayigpwqvan-odoo-18.0.20250506/lib/python3.12/site-packages/odoo/api.py", line 533, in call_kw
                        result = getattr(recs, name)(*args, **kwargs)
                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                      File "/nix/store/khhxl07bvn0mjgfx5gjw90ayigpwqvan-odoo-18.0.20250506/lib/python3.12/site-packages/odoo/addons/account/models/account_journal.py", line 966, in create_document_from_attachment
                        invoices = self._create_document_from_attachment(attachment_ids)
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                      File "/nix/store/khhxl07bvn0mjgfx5gjw90ayigpwqvan-odoo-18.0.20250506/lib/python3.12/site-packages/odoo/addons/account/models/account_journal.py", line 948, in _create_document_from_attachment
                        invoice.with_context(skip_is_manually_modified=True)._extend_with_attachments(attachment, new=True)
                      File "/nix/store/khhxl07bvn0mjgfx5gjw90ayigpwqvan-odoo-18.0.20250506/lib/python3.12/site-packages/odoo/addons/account/models/account_move.py", line 4135, in _extend_with_attachments
                        file_data_list = attachments._unwrap_edi_attachments()
                                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                      File "/nix/store/khhxl07bvn0mjgfx5gjw90ayigpwqvan-odoo-18.0.20250506/lib/python3.12/site-packages/odoo/addons/account/models/ir_attachment.py", line 160, in _unwrap_edi_attachments
                        to_process += supported_format['decoder'](attachment.name, attachment.raw)
                                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                      File "/nix/store/khhxl07bvn0mjgfx5gjw90ayigpwqvan-odoo-18.0.20250506/lib/python3.12/site-packages/odoo/addons/account/models/ir_attachment.py", line 67, in _decode_edi_pdf
                        for xml_name, xml_content in pdf_reader.getAttachments():
                                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^
                      File "/nix/store/khhxl07bvn0mjgfx5gjw90ayigpwqvan-odoo-18.0.20250506/lib/python3.12/site-packages/odoo/tools/pdf/__init__.py", line 332, in getAttachments
                        if self.isEncrypted:
                          ^^^^^^^^^^^^^^^^
                      File "/nix/store/3igil0h6bhkgpl3c5552cmii3k05mq6w-python3.12-pypdf2-3.0.1/lib/python3.12/site-packages/PyPDF2/_reader.py", line 1944, in isEncrypted
                        deprecation_with_replacement("isEncrypted", "is_encrypted", "3.0.0")
                      File "/nix/store/3igil0h6bhkgpl3c5552cmii3k05mq6w-python3.12-pypdf2-3.0.1/lib/python3.12/site-packages/PyPDF2/_utils.py", line 369, in deprecation_with_replacement
                        deprecation(DEPR_MSG_HAPPENED.format(old_name, removed_in, new_name))
                      File "/nix/store/3igil0h6bhkgpl3c5552cmii3k05mq6w-python3.12-pypdf2-3.0.1/lib/python3.12/site-packages/PyPDF2/_utils.py", line 351, in deprecation
                        raise DeprecationError(msg)
                    PyPDF2.errors.DeprecationError: isEncrypted is deprecated and was removed in PyPDF2 3.0.0. Use is_encrypted instead.

                    The above server error caused the following client error:
                    RPC_ERROR: Odoo Server Error
                        RPC_ERROR
                            at makeErrorFromResponse (https://<URL>/web/assets/17f349f/web.assets_web.min.js:3144:163)
                            at XMLHttpRequest.<anonymous> (https://<URL>/web/assets/17f349f/web.assets_web.min.js:3149:13)
                  */
                  propagatedBuildInputs =
                    builtins.filter (p: (p.pname or "") != "pypdf2") old.propagatedBuildInputs
                    ++ [
                      (pkgs.python312Packages.pypdf2.overrideAttrs (old: {
                        src = pkgs.fetchPypi {
                          pname = "PyPDF2";
                          version = "2.12.1";
                          hash = "sha256-4D7xirzHXadBoKzBp3SSU0loh744zZiHvM4c7jk9pF4=";
                        };
                      }))
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
