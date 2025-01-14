{ config, pkgs, ... }:

{
  home.username = "kwkaiser";
  home.homeDirectory = "/home/kwkaiser";
  home.stateVersion = "24.11"; # Please read the comment before changing.
  home.packages = [ ];
  home.file = { };

  home.sessionVariables = { EDITOR = "vim"; };

  programs.home-manager.enable = true;

  desktop.tiling.enable = true;
}
