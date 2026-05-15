{ config, pkgs, lib, isDarwin, ... }: {
  home.packages = with pkgs;
    lib.optionals (!isDarwin) [ keepassxc ]
    ++ [ _1password-cli _1password-gui ];
}
