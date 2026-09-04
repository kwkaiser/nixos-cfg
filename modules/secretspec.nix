{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "secretspec" (
  { pkgs, osConfig, ... }: {
    home.packages = [
      pkgs.secretspec
      (pkgs.writeShellScriptBin "ensure-kdbx-password" ''
        if [ -z "$SECRETSPEC_KDBX_PASSWORD" ]; then
          printf "kdbx password: " >&2
          read -rs SECRETSPEC_KDBX_PASSWORD
          echo >&2
          export SECRETSPEC_KDBX_PASSWORD
        fi
      '')
    ];

    xdg.configFile."secretspec/config.toml".text = ''
      [defaults]
      provider = "kdbx"

      [defaults.providers.kdbx]
      uri = "kdbx:${osConfig.mine.homeDir}/Documents/keys/keys.kdbx"
    '';

    programs.zsh.initContent = ''
      secretspec() {
        if [ "$1" = "runx" ]; then
          shift
          (
            source ensure-kdbx-password || exit 1
            command secretspec run "$@"
          )
        else
          command secretspec "$@"
        fi
      }
    '';
  }
)
