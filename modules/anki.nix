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

        username, password = sys.stdin.read().split("\n", 1)
        auth = RustBackend().sync_login(
            SyncLoginRequest(username=username, password=password.rstrip("\n"))
        )
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
            username="$(keepassxc-cli show -q -a UserName "${keysDb}" \
              "personal/services/learning/anki")"
            password="$(keepassxc-cli show -q -s -a Password "${keysDb}" \
              "personal/services/learning/anki")"
            key="$(printf '%s\n%s' "$username" "$password" \
              | PYTHONNOUSERSITE=true \
                PYTHONPATH="${pkgs.anki.lib}/${ankiPython.sitePackages}" \
                ${ankiPython.interpreter} ${ankiwebLogin})"
            unset password
            (umask 077 && printf '%s' "$username" > "${usernameFile}" \
              && printf '%s' "$key" > "${keyFile}")
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
