{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "anki" (
  { pkgs, ... }: {
    home.packages = with pkgs; [
      anki-bin
    ];
  }
)
