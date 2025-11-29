{
  config,
  pkgs,
  lib,
  bconfig,
  ...
}:
{
  programs.direnv.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
    };

    initContent = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';

  };

  home.sessionPath = [
    "$HOME/.encore/bin"
    "$HOME/.local/bin"
  ];

}
