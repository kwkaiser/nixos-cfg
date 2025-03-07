{ pkgs, config, isDarwin, lib, ... }: {
  home.packages = lib.mkIf (!isDarwin) [ pkgs.cursor-code ];
}
