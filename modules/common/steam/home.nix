{ pkgs, config, isDarwin, lib, ... }:
{
  #home.packages = lib.mkIf (!isDarwin)
  #  (with pkgs; [ steam steam-run protontricks winetricks ]);
}
