{ pkgs, config, isDarwin, lib, ... }: {
  home.packages = lib.mkIf (!isDarwin) [ pkgs.code-cursor ];

  programs.zsh.initExtra = ''
    ndc() {
      local dir="''${1:-.}"
      nix develop "$dir" -c cursor "$dir"
    }
  '';
}
