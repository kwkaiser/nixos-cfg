{
  isDarwin,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];

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

        if [ -n "$SSH_CONNECTION" ] && [ -S "$HOME/.ssh/ssh_auth_sock_link" ]; then
          SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock_link" timeout 2 ssh-add -l >/dev/null 2>&1
          if [ "$?" != 2 ]; then
            export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock_link"
          fi
        fi

        # Unbind Ctrl+a from zsh-vi-mode so tmux prefix works
        zvm_after_init() {
          bindkey -r '^a'
        }
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
