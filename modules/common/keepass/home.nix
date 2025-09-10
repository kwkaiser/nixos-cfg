{ config, pkgs, ... }: {
  home.packages = with pkgs; [ keepassxc _1password-cli _1password-gui ];
}
