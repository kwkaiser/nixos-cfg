{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "wireguard" ({ pkgs, ... }: {
  home.packages = with pkgs; [
    wireguard-tools
  ];
})
