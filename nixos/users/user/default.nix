{ config, pkgs, lib, ... }:

{
  home-manager.users."user" = ./home.nix;

  users.users."user" = {
    isNormalUser = true;
    description = "user";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "plugdev" "dialout" "docker" ] ++ (lib.optional config.networking.networkmanager.enable "networkmanager"); # TODO: docker group if docker installed

    openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGEXP+YFeEihXZGZjtvbthkNayMOXwMLLtugMS7YAdS'' ]; # TODO: ssh key from https://github.com/theverygaming.keys?
    initialPassword = "12345678";
  };

  programs.zsh.enable = true; # TODO: get rid of this if possible
  environment.shells = with pkgs; [ zsh ];

  hardware.rtl-sdr.enable = true;
}
