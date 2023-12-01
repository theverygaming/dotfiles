{ config, pkgs, ... }:

{
  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [ "networkmanager" "wheel" "plugdev" "dialout" "docker" ];
    shell = pkgs.zsh;
    initialPassword = "12345678";
  };
}
