{ config, pkgs, bconfig, ... }: {
  home.packages = with pkgs; [ nodejs_18 nodenv ];
}
