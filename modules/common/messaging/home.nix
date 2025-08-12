{ config, bconfig, pkgs, isDarwin, lib, ... }:
{

} // (if isDarwin then
  {
    # Do nothing, managed through homebrew
  }
else {
  home.packages = with pkgs; [ slack signal-desktop caprine discord whatsie ];
  services.kdeconnect.enable = true;

})
