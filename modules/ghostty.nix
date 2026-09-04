{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "ghostty" ({ pkgs, ... }: {
  programs = {
    ghostty = {
      enable = true;
      package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
      settings = {
        confirm-close-surface = false;
      };
    };
  };
})
