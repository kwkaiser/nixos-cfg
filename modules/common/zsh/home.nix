{ config, pkgs, lib, bconfig, ... }: {
  programs.direnv.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
    };

    initContent = ''
      # Homebrew (Apple Silicon)
      /opt/homebrew/bin/brew shellenv >> ~/.zshrc_homebrew_env

            if [ -f ~/.zshrc_homebrew_env ]; then
              source ~/.zshrc_homebrew_env
            fi

      export PATH="$HOME/.encore/bin:$HOME/.local/bin:$PATH"
    '';

  };

}
