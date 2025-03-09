{ config, pkgs, bconfig, ... }:
let
  # Required for node
  nodeSessionTweaks = ''
    export NVM_DIR="$HOME/.nvm"
    export PATH="/opt/homebrew/opt/jpeg/bin:$PATH"
    export LDFLAGS="-L/opt/homebrew/opt/jpeg/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/jpeg/include"
    export PKG_CONFIG_PATH="/opt/homebrew/opt/jpeg/lib/pkgconfig" 
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  '';
in {
  home.packages = with pkgs; [ nodejs_18 nodenv pango cairo pixman fontconfig ];
  programs.zsh.initExtra = lib.mkIf bconfig.mine.node.enable nodeSessionTweaks;
}
