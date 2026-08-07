{ pkgs, bconfig, ... }: {
  home.packages = [
    pkgs.secretspec
    (pkgs.writeShellScriptBin "ensure-kdbx-password" ''
      if [ -z "$SECRETSPEC_KDBX_PASSWORD" ]; then
        read -rsp "kdbx password: " SECRETSPEC_KDBX_PASSWORD
        echo >&2
        export SECRETSPEC_KDBX_PASSWORD
      fi
    '')
  ];

  xdg.configFile."secretspec/config.toml".text = ''
    [defaults]
    provider = "kdbx"

    [defaults.providers.kdbx]
    uri = "kdbx:${bconfig.mine.homeDir}/Documents/keys/keys.kdbx"
  '';
}
