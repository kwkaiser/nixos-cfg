{ config, pkgs, bconfig, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "update" ''
      cd ~/Documents/nixos-cfg && git pl && nix flake update && git commit --all --message "update flake" && git ps
    '')

    (pkgs.writeShellScriptBin "upgrade" ''
      cd ~/Documents/nixos-cfg
      if [ "$(hostname)" = "karls-MacBook-Pro" ]; then
        sudo nix run nix-darwin -- switch --flake .#work-macbook
      else
        sudo nixos-rebuild switch --flake .#$(hostname)
      fi
    '')
  ];
}
