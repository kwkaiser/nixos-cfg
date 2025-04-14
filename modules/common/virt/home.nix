{ config, pkgs, bconfig, isDarwin, ... }: {
  home.packages = with pkgs; [ qemu ];
}
