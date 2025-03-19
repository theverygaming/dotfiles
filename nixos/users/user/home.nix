{ pkgs, lib, osConfig, config, flakeInputs, ... }:

let
  isGui = osConfig.services.xserver.enable;
in
{
  imports = [
    ../../modules/common
    ../../modules/home-manager
  ] ++ builtins.concatLists [
    (lib.optional osConfig.services.xserver.desktopManager.gnome.enable ./gui/gnome.nix)
    (lib.optional osConfig.services.xserver.desktopManager.xfce.enable ./gui/xfce.nix)
    (lib.optional osConfig.programs.sway.enable ./gui/sway.nix)
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

  # TODO: this doesn't work i think lol
  nix =  {
    channels = {
      nixpkgs = flakeInputs.nixpkgs;
    };
    keepOldNixPath = false;
  };

  home.shellAliases = {
    neofetch = "hyfetch";
  };

  # for zsh
  # adds itself to ohMyZsh Plugins if ohMyZsh is enabled
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "colored-man-pages" ];
      theme = "lambda";
    };
  };
}
