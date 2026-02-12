{...}: {
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.tmux = {
    enable = true;
    shortcut = "a"; # Ctrl+a as leader key
    baseIndex = 1; # Windows start at 1
    keyMode = "vi";
    customPaneNavigationAndResize = true; # Ctrl+a + hjkl for pane navigation

    extraConfig = ''
      # Enable extended keys for Shift+Enter and other modifier combinations
      set -g extended-keys on
      set -as terminal-features 'xterm*:extkeys'
      set -as terminal-features 'xterm-kitty:extkeys'

      # Pass through Shift+Enter (CSI u encoding) for apps like Claude Code
      bind-key -n S-Enter send-keys Escape "[13;2u"

      # Map 0 to window 10
      bind-key 0 select-window -t :10

      # Split mode toggle (v = vertical, h = horizontal)
      set-environment -g SPLIT_MODE "v"

      # Toggle split mode with prefix + M
      bind-key M if-shell '[ "$(tmux show-environment -g SPLIT_MODE 2>/dev/null | cut -d= -f2)" = "v" ]' \
          'set-environment -g SPLIT_MODE "h"; display-message "Split mode: horizontal"' \
          'set-environment -g SPLIT_MODE "v"; display-message "Split mode: vertical"'

      # Create split based on current mode with prefix + Enter
      bind-key Enter if-shell '[ "$(tmux show-environment -g SPLIT_MODE 2>/dev/null | cut -d= -f2)" = "v" ]' \
          'split-window -h' \
          'split-window -v'

      # Close pane with prefix + q
      bind-key q kill-pane

      # Status bar styling
      set -g status-position top
      set -g status-justify left
      set -g status-left-length 20
      set -g status-right-length 50

      # Clean left side: session name
      set -g status-left "#[bold] #S  "

      # Clean right side: split mode indicator + date/time
      set -g status-right " #(tmux show-environment -g SPLIT_MODE 2>/dev/null | cut -d= -f2 | tr 'vh' '│─')  %H:%M "

      # Window status: cleaner format
      set -g window-status-format " #I:#W "
      set -g window-status-current-format " #I:#W "
      set -g window-status-separator "│"
    '';
  };
}
