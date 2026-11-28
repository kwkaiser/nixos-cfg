{ lib, ... }:
let
  inherit (import ../../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "tmt" (
  { inputs, ... }:
  {
    imports = [ inputs.tmt-go.homeModules.default ];

    programs.tmt = {
      enable = true;
      settings.dirs."~/Documents/agents-of-chaos" = lib.mkDefault "codex";
    };
  }
)
