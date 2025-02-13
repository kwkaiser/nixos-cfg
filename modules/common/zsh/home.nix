{ config, pkgs, ... }: {
  programs.direnv.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
    };
  };
}
