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
      # Map 0 to window 10
      bind-key 0 select-window -t :10
    '';
  };
}
