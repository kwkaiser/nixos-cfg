{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "borgmatic" ({ pkgs, ... }: {
  home.packages = with pkgs; [
    borgbackup
    borgmatic
  ];
})
