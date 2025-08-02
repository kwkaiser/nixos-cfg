{ config, pkgs, bconfig, ... }: {
  home.packages = with pkgs; [ nodejs_20 nodenv pango cairo pixman fontconfig ];
}
