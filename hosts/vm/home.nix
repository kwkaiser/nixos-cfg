{ config, pkgs, lib, ... }: {
  home.packages = [ pkgs.zsh ];
  programs.zsh.enable = true;
}
