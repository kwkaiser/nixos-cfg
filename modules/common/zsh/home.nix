{
  config,
  pkgs,
  lib,
  bconfig,
  isDarwin
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

    # TODO: find better home for this
    shellAliases = {
      k = "kubectl";
    };

  }
  // (
    if isDarwin then
      {
        initContent = ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        '';
      }
    else
      {

      }
  );

  home.sessionPath = [
    "$HOME/.encore/bin"
    "$HOME/.local/bin"
  ];

}
