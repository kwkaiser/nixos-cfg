{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "virt" (
  { pkgs, lib, ... }: {
    home.packages = with pkgs; [ qemu ] ++ lib.optionals pkgs.stdenv.isDarwin [ utm ];
  }
)
