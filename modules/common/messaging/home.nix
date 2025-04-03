{ config, pkgs, isDarwin, lib, ... }: {
  home.packages = with pkgs; [ slack signal-desktop caprine discord ];
  services = lib.mkIf (!isDarwin) { kdeconnect.enable = true; };
}
