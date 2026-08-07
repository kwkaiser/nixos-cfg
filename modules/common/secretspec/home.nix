{ pkgs, bconfig, ... }: {
  home.packages = [ pkgs.secretspec ];

  xdg.configFile."secretspec/config.toml".text = ''
    [defaults.providers.kdbx]
    uri = "kdbx:${bconfig.mine.homeDir}/Documents/keys/keys.kdbx"
  '';
}
