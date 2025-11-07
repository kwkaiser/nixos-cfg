{ config, pkgs, bconfig, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "update" ''
      cd ~/Documents/nixos-cfg && nix flake update && git commit --all --message "update flake" && git ps
    '')

    (pkgs.writeShellScriptBin "upgrade" ''
      cd ~/Documents/nixos-cfg && sudo nixos-rebuild switch --flake .#$(hostname)
    '')
  ];
}
