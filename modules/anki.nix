{lib, ...}: let
  inherit (import ../dendritic-lib.nix {inherit lib;}) mkHmFeature;
in
  mkHmFeature "anki" (
    {
      config,
      pkgs,
      inputs,
      osConfig,
      ...
    }: let
      customAddons = inputs.anki.packages.${pkgs.stdenv.hostPlatform.system};
      keysDb = "${osConfig.mine.homeDir}/Documents/keys/keys.kdbx";
      syncDir = "${config.xdg.stateHome}/anki-sync";
      usernameFile = "${syncDir}/username";
      keyFile = "${syncDir}/key";
      ankiPython = pkgs.anki.python;

      ankiwebLogin = pkgs.writeText "ankiweb-login.py" ''
        import sys

        from anki._backend import RustBackend
        from anki.sync_pb2 import SyncLoginRequest

        username, password = sys.stdin.read().rstrip("\n").split("\n", 1)
        print("Logging in to AnkiWeb...", file=sys.stderr, flush=True)
        auth = RustBackend().sync_login(
            SyncLoginRequest(username=username, password=password)
        )
        print(username)
        print(auth.hkey)
      '';

      ignoreLauncherFileOpen = pkgs.anki-utils.buildAnkiAddon {
        pname = "ignore-launcher-file-open";
        version = "1.0";
        src = pkgs.writeTextDir "__init__.py" ''
          import sys
          from pathlib import Path

          import aqt.main

          launcher_dir = Path(sys.argv[0]).resolve().parent
          handle_import = aqt.main.AnkiQt.handleImport

          def patched_handle_import(self, path: str) -> None:
              if Path(path).resolve().parent == launcher_dir:
                  return None
              return handle_import(self, path)

          aqt.main.AnkiQt.handleImport = patched_handle_import
        '';
      };
    in {
      programs.anki = {
        enable = true;
        addons = [
          pkgs.ankiAddons.anki-connect
          customAddons.hello-world
          customAddons.dynamic-llm
          ignoreLauncherFileOpen
        ];
        profiles."User 1".sync = {
          inherit usernameFile keyFile;
        };
      };

      home.packages = [
        (pkgs.writeShellScriptBin "sanki" ''
          set -euo pipefail

          if [ ! -s "${keyFile}" ] || [ ! -s "${usernameFile}" ]; then
            mkdir -p "${syncDir}"
            chmod 700 "${syncDir}"
            echo "No cached AnkiWeb sync key; reading credentials from keepassxc" >&2
            username=""
            key=""
            {
              read -r username || true
              read -r key || true
            } < <(keepassxc-cli show -s -a UserName -a Password "${keysDb}" \
              "personal/services/learning/anki" \
              | PYTHONNOUSERSITE=true \
                PYTHONPATH="${pkgs.anki.lib}/${ankiPython.sitePackages}" \
                ${ankiPython.interpreter} ${ankiwebLogin})
            if [ -z "$key" ]; then
              echo "AnkiWeb login failed" >&2
              exit 1
            fi
            (umask 077 && printf '%s' "$username" > "${usernameFile}" \
              && printf '%s' "$key" > "${keyFile}")
            echo "Cached AnkiWeb sync key in ${syncDir}" >&2
          fi

          OPENROUTER_API_KEY="$(keepassxc-cli show -s -a Password \
            "${keysDb}" \
            "personal/projects/homelab/openrouter api key")"
          export OPENROUTER_API_KEY
          exec anki "$@"
        '')
      ];
    }
  )
