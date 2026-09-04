{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "python" ({ pkgs, ... }: {
  home.packages = with pkgs; [
    python3
    uv
    (pipx.overridePythonAttrs (old: { doCheck = false; }))
  ];
})
