{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "anki" (
  { pkgs, inputs, ... }:
  let
    customAddons = inputs.anki.packages.${pkgs.stdenv.hostPlatform.system};
  in
  {
    programs.anki = {
      enable = true;
      addons = [
        pkgs.ankiAddons.anki-connect
        customAddons.hello-world
      ];
    };
  }
)
