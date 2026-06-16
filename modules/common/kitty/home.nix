{ pkgs, config, ... }: {
  programs = {
    kitty = {
      enable = true;
      extraConfig = ''
        confirm_os_window_close 0
        paste_actions no-op

        # Shift+Enter sends newline in Claude Code (even inside tmux/neovim)
        map shift+enter send_text all \x1b\r

        # DejaVu Sans Mono lacks many symbols (●, ❯, ✢, ⏵, etc.), causing fontconfig
        # to fall back to proportional DejaVu Sans. Proportional glyphs render wider than
        # 1 cell, but TUI apps (Claude Code, etc.) count them as 1 cell — causing layout
        # corruption. Force these ranges to Unifont which is strictly 1-cell-wide.
        symbol_map U+25A0-U+25FF Unifont
        symbol_map U+2700-U+27FF Unifont
      '';
    };

  };
}
