{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "handy" (
  { pkgs, ... }: {
    home.packages = with pkgs; [
      handy
    ];
  }
)
