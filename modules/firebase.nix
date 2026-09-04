{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "firebase" ({ pkgs, ... }: {
  home.packages = with pkgs; [
    firebase-tools
  ];
})
