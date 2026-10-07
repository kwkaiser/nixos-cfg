{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "java" (
  { pkgs, ... }: {
    home.packages = with pkgs; [
      openjdk
    ];
  }
)
