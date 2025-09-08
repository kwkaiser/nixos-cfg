{ config, bconfig, pkgs, isDarwin, lib, ... }:
{

} // (if isDarwin then
  {
    # Do nothing, managed through homebrew
  }
else {
  home.packages = with pkgs; [ slack signal-desktop caprine discord ];
  services.kdeconnect.enable = true;

})
