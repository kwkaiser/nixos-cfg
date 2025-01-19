{ config, pkgs, ... }:

{
  programs.bash.shellAliases = { ll = "ls -lah"; };
  home.packages = with pkgs; [ htop ];
}
