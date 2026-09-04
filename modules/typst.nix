{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "typst" (
  { pkgs, ... }: {
    home.packages = with pkgs; [
      typst
      poppler-utils

      lato
      font-awesome
    ];
  }
)
