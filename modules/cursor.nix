{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "cursor" (
  { pkgs, lib, ... }: {
    home.packages = lib.mkIf (!pkgs.stdenv.isDarwin) [ pkgs.code-cursor ];

    programs.zsh.initContent = ''
      ndc() {
        local dir="''${1:-.}"
        nix develop "$dir" -c cursor "$dir"
      }
    '';
  }
)
