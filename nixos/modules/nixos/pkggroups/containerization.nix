{ config, lib, pkgs, ... }:

let
  cfg = config.custom.pkggroups.containerization;
in {
  options.custom.pkggroups.containerization = {
    enable = lib.mkEnableOption "Enable Containerization packages (e.g. docker, docker compose)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ 
      docker-compose
    ];
    virtualisation.docker.enable = lib.mkDefault true;
  };
}
