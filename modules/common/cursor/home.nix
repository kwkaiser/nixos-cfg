{ pkgs, config, isDarwin, lib, ... }: {
  home.packages =
    lib.mkIf (!isDarwin) [ pkgs.code-cursor pkgs.claude-code pkgs.vscode ];

  programs.zsh.initContent = ''
    ndc() {
      local dir="''${1:-.}"
      nix develop "$dir" -c cursor "$dir"
    }
  '';
}
