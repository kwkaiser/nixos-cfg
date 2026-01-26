{ config, pkgs, bconfig, ... }: {

  programs.neovim = {
    defaultEditor = true;
    enable = true;
    vimAlias = true;
  };
}
