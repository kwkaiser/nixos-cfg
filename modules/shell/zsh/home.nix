{ config, pkgs, ... }: {

  home.shell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    ohMyZsh.enable = true;
    plugins = [ "git" "zsh-autosuggestions" ];
    theme = "robbyrussell";
  };
}
