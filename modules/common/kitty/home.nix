{ pkgs, config, inputs, ... }: {
  programs = {
    kitty = {
      enable = true;
      # Current nixos-unstable's ld64/libclang_rt combo crashes
      # (Trace/BPT trap: 5) linking kitty's cocoa glfw backend on Darwin.
      package = inputs.nixpkgs-darwin-stable.legacyPackages.${pkgs.system}.kitty;
      extraConfig = ''
        confirm_os_window_close 0
        paste_actions no-op

        # Shift+Enter sends newline in Claude Code (even inside tmux/neovim)
        map shift+enter send_text all \x1b\r
      '';
    };

  };
}
