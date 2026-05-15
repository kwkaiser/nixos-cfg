{ config, pkgs, lib, isDarwin, ... }:

{
  home.stateVersion = "24.11";

  # Silence gtk.gtk4.theme legacy-default warning (stateVersion < 26.05)
  gtk.gtk4.theme = lib.mkIf config.gtk.enable null;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = lib.optionals isDarwin [
    (final: prev: {
      # TODO: remove — direnv zsh tests hang in macOS sandbox
      direnv = prev.direnv.overrideAttrs (old: {
        doCheck = false;
        checkPhase = "";
      });
    })
  ];
}
