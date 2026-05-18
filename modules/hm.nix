{
  config,
  lib,
  ...
}: {
  home.stateVersion = "24.11";

  # Silence gtk.gtk4.theme legacy-default warning (stateVersion < 26.05)
  gtk.gtk4.theme = lib.mkIf config.gtk.enable null;
  nixpkgs.config.allowUnfree = true;
}
