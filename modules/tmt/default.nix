{ lib, ... }:
let
  inherit (import ../../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "tmt" (
  { pkgs, config, ... }:
  let
    colors = config.lib.stylix.colors;
    hex = colors.withHashtag;
    sgr = base: "38;2;${colors."${base}-rgb-r"};${colors."${base}-rgb-g"};${colors."${base}-rgb-b"}";

    fzfColors = lib.concatStringsSep "," [
      "fg:${hex.base05}"
      "bg:-1"
      "hl:${hex.base09}"
      "fg+:${hex.base06}"
      "bg+:${hex.base01}"
      "hl+:${hex.base09}"
      "gutter:-1"
      "query:${hex.base05}"
      "info:${hex.base03}"
      "prompt:${hex.base0D}"
      "pointer:${hex.base09}"
      "marker:${hex.base0B}"
      "spinner:${hex.base0C}"
      "header:${hex.base03}"
      "border:${hex.base02}"
      "separator:${hex.base02}"
      "scrollbar:${hex.base02}"
      "label:${hex.base0A}"
      "preview-border:${hex.base02}"
      "preview-label:${hex.base04}"
    ];

    clonedir = pkgs.writeCBin "clonedir" ''
      #include <stdio.h>
      #include <sys/clonefile.h>

      int main(int argc, char **argv) {
        if (argc != 3) {
          fprintf(stderr, "usage: clonedir <src> <dst>\n");
          return 2;
        }
        if (clonefile(argv[1], argv[2], CLONE_NOFOLLOW) != 0) {
          perror("clonefile");
          return 1;
        }
        return 0;
      }
    '';

    tmt = pkgs.writeShellApplication {
      name = "tmt";
      runtimeInputs = [
        config.programs.tmux.package
        pkgs.git
        pkgs.fzf
        pkgs.gh
        pkgs.tea
        pkgs.zoxide
        pkgs.gawk
        pkgs.jq
        pkgs.gum
      ]
      ++ lib.optional pkgs.stdenv.hostPlatform.isDarwin clonedir;
      text = ''
        fzf_colors=${lib.escapeShellArg fzfColors}
        sgr_worktree=${lib.escapeShellArg (sgr "base0B")}
        sgr_main=${lib.escapeShellArg (sgr "base03")}
        sgr_root=${lib.escapeShellArg (sgr "base0D")}
        sgr_accent=${lib.escapeShellArg (sgr "base0A")}
        sgr_dim=${lib.escapeShellArg (sgr "base04")}
      ''
      + builtins.readFile ./tmt.sh;
    };
  in
  {
    home.packages = [
      tmt
      (pkgs.writeTextDir "share/zsh/site-functions/_tmt" (builtins.readFile ./_tmt.zsh))
    ];
  }
)
