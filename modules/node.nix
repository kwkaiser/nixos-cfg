{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "node" (
  { pkgs, ... }: {
    home.packages = with pkgs; [
      nodejs_24
      nodenv
      pango
      cairo
      pixman
      fontconfig
    ];
  }
)
