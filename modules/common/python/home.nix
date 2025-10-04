{ config, pkgs, bconfig, ... }: {
  home.packages = with pkgs; [ python3 uv pipx ];
}
