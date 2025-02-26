{ config, pkgs, ... }: {
  programs.direnv.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
    };
    initExtra = ''
      export NVM_DIR="$HOME/.nvm"
      export PATH="/opt/homebrew/opt/jpeg/bin:$PATH"
      export LDFLAGS="-L/opt/homebrew/opt/jpeg/lib"
      export CPPFLAGS="-I/opt/homebrew/opt/jpeg/include"
      export PKG_CONFIG_PATH="/opt/homebrew/opt/jpeg/lib/pkgconfig" 
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    '';
  };
}
