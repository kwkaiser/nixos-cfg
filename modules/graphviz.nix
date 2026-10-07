{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "graphviz" (
  { pkgs, ... }: {
    home.packages = with pkgs; [
      graphviz
    ];
  }
)
