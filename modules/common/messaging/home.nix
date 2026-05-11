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
  # signal-desktop is excluded on Darwin — installed via Homebrew cask to stay current
  home.packages = with pkgs; [
    slack
    caprine
    discord
  ] ++ lib.optionals (!isDarwin) [ signal-desktop ];
}
// lib.optionalAttrs (!isDarwin) {
  # Only enable KDE Connect on non-Darwin systems
  services.kdeconnect.enable = true;
}
