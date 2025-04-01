{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    slack
    signal-desktop
    caprine
    discord
  ];
} 