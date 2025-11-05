{ pkgs, config, isDarwin, lib, ... }: {
  home.packages = lib.mkIf (!isDarwin) [ pkgs.code-cursor ];

  home.shellAliases = { ndc = "nix develop && cursor ."; };
}
