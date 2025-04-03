{ pkgs, config, isDarwin, lib, ... }: {
  home.packages = lib.mkIf (!isDarwin) [ pkgs.code-cursor ];
}
