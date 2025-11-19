{ pkgs, config, isDarwin, lib, ... }: {
  home.packages = lib.mkIf (!isDarwin) [ pkgs.code-cursor ];

  programs.zsh.initContent = ''
    ndc() {
      local dir="''${1:-.}"
      nix develop "$dir" -c cursor "$dir"
    }
  '';
}
