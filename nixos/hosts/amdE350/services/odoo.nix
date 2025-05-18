{ flakeInputs, ... }:

{
  custom.microvm = {
    enable = true;
    vms = {
      "odoo" = {
        id = "1";
        ip = "10.69.0.2";
        modules = [
          (
            { pkgs, ... }:
            {
              microvm = {
                mem = 2048;
                vcpu = 2;
              };
              services.odoo = {
                enable = true;
                package = pkgs.odoo;
                settings = {
                  options = { };
                };
                autoInit = true;
              };
              systemd.services.odoo = {
                serviceConfig.TimeoutStartSec = "20min"; # Odoo can take a while to initialize, esp under high system load
                serviceConfig.Restart = "on-failure";
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
