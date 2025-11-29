{
  config,
  bconfig,
  pkgs,
  isDarwin,
  lib,
  ...
}:
{
  # Always install messaging packages through home-manager
  home.packages = with pkgs; [
    slack
    signal-desktop-bin
    caprine
    discord
  ];
}
// lib.optionalAttrs (!isDarwin) {
  # Only enable KDE Connect on non-Darwin systems
  services.kdeconnect.enable = true;
}
