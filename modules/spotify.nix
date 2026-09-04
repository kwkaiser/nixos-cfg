{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "spotify" ({ pkgs, ... }: { home.packages = with pkgs; [ spotify ]; })
