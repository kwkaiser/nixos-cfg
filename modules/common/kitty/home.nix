{ pkgs, config, ... }: {
  programs = {
    kitty = {
      enable = true;
      extraConfig = ''
        confirm_os_window_close 0

        # Shift+Enter sends newline in Claude Code (even inside tmux/neovim)
        map shift+enter send_text all \x1b\r
      '';
    };

  };
}
