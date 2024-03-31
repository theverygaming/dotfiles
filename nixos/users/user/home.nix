{ pkgs, lib, osConfig, config, ... }:

let
  isGui = osConfig.services.xserver.enable;
in {
  imports = builtins.concatLists [
    (lib.optional osConfig.services.xserver.desktopManager.gnome.enable ./gui/gnome.nix)
    #(lib.optional osConfig.services.desktopManager.plasma6.enable ./gui/plasma6.nix)
  ];
  
  home.username = "user";
  home.homeDirectory = "/home/user";

  home.sessionVariables = {
    EDITOR = "nano";
  };

  # TODO: shell config here
  # TODO: git config here
  # TODO: vscode config here

  xdg.userDirs.enable = isGui;
  
  programs.home-manager.enable = true;
  home.stateVersion = "23.05";
}
