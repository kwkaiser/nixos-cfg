{ config, pkgs, lib, ... }: {
  # options = {
  #   bingus.shell.zsh = lib.mkEnableOption "should use zsh as home shell";
  # };

  home.packages = [ pkgs.zsh ];
  programs.zsh.enable = true;

}
