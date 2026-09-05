{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "tailcat" (
  { pkgs, ... }: {
    home.packages = with pkgs; [
      tailcat
    ];
  }
)
