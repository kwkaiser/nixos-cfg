{
  pkgs,
  lib,
  inputs,
  ...
}: let
  # Plain-tmux equivalent of the tmuxinator-based `tma` on the main
  # workstation, without the ~94MiB ruby/tmuxinator dependency - this box
  # only ever needs the one fixed claude/editor/driver layout. `ccp` comes
  # from the imported claude module, resolved via $PATH at runtime.
  tma = pkgs.writeShellScriptBin "tma" ''
    set -euo pipefail
    dir="''${1:-$HOME}"
    session="devbox"
    if tmux has-session -t "$session" 2>/dev/null; then
      exec tmux attach -t "$session"
    fi
    tmux new-session -d -s "$session" -n claude -c "$dir" 'ccp'
    tmux new-window -t "$session" -n editor -c "$dir"
    tmux new-window -t "$session" -n driver -c "$dir"
    tmux select-window -t "$session:claude"
    exec tmux attach -t "$session"
  '';
in {
  imports = [
    # git/neovim/claude/codex home-manager config comes from the dendritic
    # registry instead (config.homeManager.modules.*) - wired in by the
    # caller (../devbox/image.nix), since this file has no access to the
    # flake-parts top-level config on its own.
    inputs.nvf.homeManagerModules.default
  ];

  home.username = "root";
  home.homeDirectory = "/root";
  home.stateVersion = "25.05";

  # git/home.nix wires this to gitFull's git-credential-libsecret on Linux,
  # which needs a running keyring daemon this headless box will never have,
  # and drags in gitFull (git-with-svn, ~474MiB) just for the string
  # reference. Blank it - ssh-based auth doesn't need a credential helper.
  programs.git.settings.credential.helper = lib.mkForce "";

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      ForwardAgent = true;
      ServerAliveInterval = 300;
      ServerAliveCountMax = 2;
      TCPKeepAlive = "yes";
    };
  };
  home.file.".ssh/rc" = {
    executable = true;
    text = ''
      #!/bin/sh
      if [ -n "$SSH_AUTH_SOCK" ]; then
        ln -sf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_auth_sock_link"
      fi
    '';
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
    keyMode = "vi";
  };

  home.packages = with pkgs; [
    nodejs_24
    uv
    pnpm
    inputs.nixpkgs-devbox.legacyPackages.${pkgs.stdenv.hostPlatform.system}.devbox
    tma
  ];
}
