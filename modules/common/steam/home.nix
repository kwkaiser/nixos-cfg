{ pkgs, config, isDarwin, ... }: {
  home.packages = with pkgs;
    [ steam steam-run ] ++ lib.optionals (!isDarwin) [

      protontricks
      winetricks
    ];
}
