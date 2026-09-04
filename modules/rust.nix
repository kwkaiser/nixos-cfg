{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "rust" ({ pkgs, ... }: {
  home.packages = with pkgs; [
    cargo
    rustc
    rust-analyzer
    rustfmt
    clippy
  ];
})
