{ config, pkgs, bconfig, ... }: {
  programs.neovim = {
    enable = true;
    vimAlias = true;
  };
}
