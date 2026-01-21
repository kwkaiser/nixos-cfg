{
  config,
  pkgs,
  bconfig,
  ...
}:
{
  home.packages = with pkgs; [
    fzf
    nix-search-tv

    (writeShellScriptBin "ns" ''
      nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history
    '')

    (writeShellScriptBin "update" ''
      cd ~/Documents/nixos-cfg && git pl && nix flake update && git commit --all --message "update flake" && git ps
    '')

    (writeShellScriptBin "cleanup" ''
      nix-collect-garbage -d && sudo nix-collect-garbage -d
    '')

    (writeShellScriptBin "upgrade" ''
      cd ~/Documents/nixos-cfg
      if [ "$(hostname)" = "karls-MacBook-Pro" ]; then
        sudo nix run nix-darwin -- switch --flake .#work-macbook
      else
        sudo nixos-rebuild switch --flake .#$(hostname)
      fi
    '')
  ];
}
