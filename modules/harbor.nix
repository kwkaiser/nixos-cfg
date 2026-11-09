{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "harbor" (
  { pkgs, ... }: {
    home.packages = [
      (pkgs.writeShellScriptBin "harbor" ''
        exec ${pkgs.uv}/bin/uvx --from git+https://github.com/harbor-framework/harbor@2bc1a23bd961de0bec8742940f35ac9070c67815 harbor "$@"
      '')
    ];
  }
)
