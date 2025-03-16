{ pkgs, config, lib, ... }: {
  home.packages = with pkgs;
    [ obsidian ] ++ lib.optionals config.mine.notes.untrusted [ cryptomator ];
}
