{pkgs, ...}: {
  home.packages = with pkgs; [
    tmuxinator
  ];

  programs.tmux = {
    enable = true;
    shortcut = "a"; # Ctrl+a as leader key
    baseIndex = 1; # Windows start at 1
    keyMode = "vi";
    customPaneNavigationAndResize = false;

    extraConfig = ''
      # Terminal and keyboard settings for Kitty/modern terminals
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ",xterm-kitty:Tc"
      set -ga terminal-overrides ",*:RGB"
      set -g mouse on

      # Extended keys for Shift+Enter etc.
      set -s extended-keys on
      set -as terminal-features 'xterm-kitty:extkeys:clipboard:RGB'

      # Allow passthrough for escape sequences
      set -g allow-passthrough on

      # Immediate escape key (no delay for vi mode)
      set -sg escape-time 0

      # Manual Shift+Enter passthrough as fallback
      bind-key -n S-Enter send-keys Escape "[13;2u"

      # Window navigation with [ and ] (like Hyprland mod+[/])
      bind-key '[' previous-window
      bind-key ']' next-window

      # Select window 1-10, auto-create if doesn't exist
      bind-key 1 run-shell 'tmux select-window -t :1 2>/dev/null || tmux new-window -t :1'
      bind-key 2 run-shell 'tmux select-window -t :2 2>/dev/null || tmux new-window -t :2'
      bind-key 3 run-shell 'tmux select-window -t :3 2>/dev/null || tmux new-window -t :3'
      bind-key 4 run-shell 'tmux select-window -t :4 2>/dev/null || tmux new-window -t :4'
      bind-key 5 run-shell 'tmux select-window -t :5 2>/dev/null || tmux new-window -t :5'
      bind-key 6 run-shell 'tmux select-window -t :6 2>/dev/null || tmux new-window -t :6'
      bind-key 7 run-shell 'tmux select-window -t :7 2>/dev/null || tmux new-window -t :7'
      bind-key 8 run-shell 'tmux select-window -t :8 2>/dev/null || tmux new-window -t :8'
      bind-key 9 run-shell 'tmux select-window -t :9 2>/dev/null || tmux new-window -t :9'
      bind-key 0 run-shell 'tmux select-window -t :10 2>/dev/null || tmux new-window -t :10'

      # Split orientation (like Hyprland orientationbottom/orientationright)
      set-environment -g SPLIT_MODE "v"

      # Set split orientation with v/V (like Hyprland mod+v / mod+shift+v)
      bind-key v set-environment -g SPLIT_MODE "h" \; display-message "Split: horizontal (stacked)"
      bind-key V set-environment -g SPLIT_MODE "v" \; display-message "Split: vertical (side-by-side)"

      # Create split based on current mode with prefix + Enter (inherits working directory)
      bind-key Enter if-shell '[ "$(tmux show-environment -g SPLIT_MODE 2>/dev/null | cut -d= -f2)" = "v" ]' \
          'split-window -h -c "#{pane_current_path}"' \
          'split-window -v -c "#{pane_current_path}"'

      # Create mode: prefix + c, then w/s for window/session
      bind-key c switch-client -T create
      bind-key -T create w new-window
      bind-key -T create s new-session

      # Rename: prefix + r, then w/s for window/session
      bind-key r switch-client -T rename
      bind-key -T rename w command-prompt -I "#W" "rename-window '%%'"
      bind-key -T rename s command-prompt -I "#S" "rename-session '%%'"

      # Reload config with prefix + Shift+r
      bind-key R source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded"

      # Close pane with prefix + q
      bind-key q kill-pane

      # Zoom/fullscreen pane with prefix + f (like Hyprland mod+f)
      bind-key f resize-pane -Z

      # Pane focus with hjkl (like WM mod+hjkl)
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      # Swap panes with Shift+hjkl (like WM mod+shift+hjkl)
      bind-key H swap-pane -s '{left-of}'
      bind-key J swap-pane -s '{down-of}'
      bind-key K swap-pane -s '{up-of}'
      bind-key L swap-pane -s '{right-of}'

      # Move pane to window with Shift+number, auto-create window if needed
      bind-key '!' run-shell 'tmux join-pane -t :1 || (tmux new-window -d -t :1 && tmux join-pane -t :1) || :'
      bind-key '@' run-shell 'tmux join-pane -t :2 || (tmux new-window -d -t :2 && tmux join-pane -t :2) || :'
      bind-key '#' run-shell 'tmux join-pane -t :3 || (tmux new-window -d -t :3 && tmux join-pane -t :3) || :'
      bind-key '$' run-shell 'tmux join-pane -t :4 || (tmux new-window -d -t :4 && tmux join-pane -t :4) || :'
      bind-key '%' run-shell 'tmux join-pane -t :5 || (tmux new-window -d -t :5 && tmux join-pane -t :5) || :'
      bind-key '^' run-shell 'tmux join-pane -t :6 || (tmux new-window -d -t :6 && tmux join-pane -t :6) || :'
      bind-key '&' run-shell 'tmux join-pane -t :7 || (tmux new-window -d -t :7 && tmux join-pane -t :7) || :'
      bind-key '*' run-shell 'tmux join-pane -t :8 || (tmux new-window -d -t :8 && tmux join-pane -t :8) || :'
      bind-key '(' run-shell 'tmux join-pane -t :9 || (tmux new-window -d -t :9 && tmux join-pane -t :9) || :'
      bind-key ')' run-shell 'tmux join-pane -t :10 || (tmux new-window -d -t :10 && tmux join-pane -t :10) || :'

      # Status bar styling
      set -g status-position top
      set -g status-justify left
      set -g status-left-length 20
      set -g status-right-length 50

      # Clean left side: session name
      set -g status-left "#[bold] #S  "

      # Clean right side: split mode indicator + zoom status + date/time
      set -g status-right " #{?window_zoomed_flag,(zoomed) ,}#(tmux show-environment -g SPLIT_MODE 2>/dev/null | cut -d= -f2 | tr 'vh' '│─')  %H:%M "

      # Window status: cleaner format
      set -g window-status-format " #I:#W "
      set -g window-status-current-format " #I:#W "
      set -g window-status-separator "│"
    '';
  };
}
