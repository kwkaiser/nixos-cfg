{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "harbor" (
  { pkgs, ... }: {
    home.packages = [
      (pkgs.writeShellScriptBin "harbor" ''
        exec ${pkgs.uv}/bin/uvx harbor "$@"
      '')
    ];
  }
)
