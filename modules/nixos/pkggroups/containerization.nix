{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.pkggroups.containerization;
in
{
  options.custom.pkggroups.containerization = {
    enable = lib.mkEnableOption "Enable Containerization packages (e.g. docker, docker compose)";
    rootless = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        use rootless docker and stuff
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      docker-compose
    ];
    virtualisation.docker =
      if cfg.rootless then
        {
          rootless = {
            enable = true;
            setSocketVariable = true;
          };

        }
      else
        {
          enable = lib.mkDefault true;
        };
  };
}
