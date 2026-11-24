{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "anki" (
  { pkgs, inputs, osConfig, ... }:
  let
    customAddons = inputs.anki.packages.${pkgs.stdenv.hostPlatform.system};
  in
  {
    programs.anki = {
      enable = true;
      addons = [
        pkgs.ankiAddons.anki-connect
        customAddons.hello-world
        customAddons.dynamic-llm
      ];
    };

    home.packages = [
      (pkgs.writeShellScriptBin "sanki" ''
        set -euo pipefail
        OPENROUTER_API_KEY="$(keepassxc-cli show -s -a Password \
          "${osConfig.mine.homeDir}/Documents/keys/keys.kdbx" \
          "personal/projects/homelab/housing openrouter api key")"
        export OPENROUTER_API_KEY
        exec anki "$@"
      '')
    ];
  }
)
