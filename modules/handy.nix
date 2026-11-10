{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "handy" (
  { pkgs, inputs, ... }: {
    home.packages = [
      inputs.nixpkgs-darwin-cached.legacyPackages.${pkgs.stdenv.hostPlatform.system}.handy
    ];
  }
)
