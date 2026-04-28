{ config, pkgs, lib, isDarwin, ... }:

{
  home.stateVersion = "24.11";
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
