{
  config,
  pkgs,
  lib,
  flakeInputs,
  ...
}:

{
  home-manager.backupFileExtension = "hmbackup";
  home-manager.users."user" = ./home.nix;

  sops.secrets.user_pwd_hash = {
    neededForUsers = true;
    sopsFile = flakeInputs.secrets + "/common/users.yaml";
  };

  programs.zsh.enable = true; # The shell is set on system level, home-manager can't do it

  users.users."user" = {
    isNormalUser = true;
    description = "user";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "plugdev"
      "dialout"
      "docker"
    ] ++ (lib.optional config.networking.networkmanager.enable "networkmanager"); # TODO: docker group if docker installed

    openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGEXP+YFeEihXZGZjtvbthkNayMOXwMLLtugMS7YAdS''
    ]; # TODO: ssh key from https://github.com/theverygaming.keys?
    hashedPasswordFile = config.sops.secrets.user_pwd_hash.path;
  };
}
