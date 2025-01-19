{ config, pkgs, ... }:

{
  programs.bash.shellAliases = { ll = "ls -lah"; };
}
