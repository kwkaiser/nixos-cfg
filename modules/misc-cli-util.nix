{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "misc-cli-util" (
  { pkgs, ... }: {
    home.packages = with pkgs; [
      terminal-rain-lightning
      pipes
      gnumake
      go-task
    ];

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  }
)
