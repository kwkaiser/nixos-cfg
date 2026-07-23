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
  # signal-desktop and slack are excluded on Darwin — installed via Homebrew cask instead
  home.packages = with pkgs; [
    caprine
    discord
  ] ++ lib.optionals (!isDarwin) [
    signal-desktop
    slack
  ];
}
// lib.optionalAttrs (!isDarwin) {
  # Only enable KDE Connect on non-Darwin systems
  services.kdeconnect.enable = true;
}
