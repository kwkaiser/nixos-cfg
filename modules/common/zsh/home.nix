{isDarwin, ...}: {
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

    initContent =
      ''
        stty -ixon  # Allow Ctrl+S/Ctrl+Q to pass through to applications
      ''
      + (
        if isDarwin
        then ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        ''
        else ""
      );
  };

  home.sessionPath = [
    "$HOME/.encore/bin"
    "$HOME/.local/bin"
  ];
}
