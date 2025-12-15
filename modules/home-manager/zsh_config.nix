{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.zsh_config;
in
{
  options.custom.zsh_config = {
    enable = lib.mkEnableOption "Enable zsh config";
  };

  config = lib.mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "colored-man-pages"
        ];
        theme = "lambda";
      };
    };
  };
}
