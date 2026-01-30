{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.aero.enable =
      lib.mkEnableOption "Whether or not to use aerospace shell";
  };

  config = lib.mkIf config.mine.aero.enable {
    services.aerospace.enable = true;
    system.defaults.dock.autohide = true;
    system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;

    # Disable macOS shortcuts that conflict with aerospace bindings
    system.defaults.CustomUserPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          "28" = { enabled = false; };  # Cmd+Shift+3 (screenshot to file)
          "29" = { enabled = false; };  # Cmd+Ctrl+Shift+3 (screenshot to clipboard)
          "30" = { enabled = false; };  # Cmd+Shift+4 (selection to file)
          "31" = { enabled = false; };  # Cmd+Ctrl+Shift+4 (selection to clipboard)
          "184" = { enabled = false; }; # Cmd+Shift+5 (screenshot menu)
        };
      };
      # Remap logout menu item to Ctrl+Opt+Cmd+Shift+Q to free up Cmd+Shift+Q
      NSGlobalDomain = {
        NSUserKeyEquivalents = {
          "Log Out ${config.mine.username}\\U2026" = "@~^$q";  # Ctrl+Opt+Cmd+Shift+Q
        };
      };
    };

    # Apply keyboard shortcut changes immediately without requiring logout
    system.activationScripts.postActivation.text = ''
      sudo -u ${config.mine.username} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    services.aerospace.settings = {
      mode.main.binding = {
        # cmd-h = "focus left";
        # cmd-j = "focus down";
        # cmd-k = "focus up";
        # cmd-l = "focus right";
        cmd-shift-q = "close";  # Close window (like hyprland mod+shift+q)
        cmd-shift-h = "move left";
        cmd-shift-j = "move down";
        cmd-shift-k = "move up";
        cmd-shift-l = "move right";
        cmd-comma = "layout h_tiles";
        cmd-shift-comma = "layout v_tiles";
        cmd-backslash = "layout tiling";
        cmd-shift-backslash = "layout floating tiling";

        # Tabbing/accordion (consistent with hyprland groups)
        cmd-s = "layout accordion tiles";  # Toggle tabbed/tiled (like hyprland togglegroup)
        cmd-leftSquareBracket = "focus left";    # Focus prev tab (like hyprland changegroupactive b)
        cmd-rightSquareBracket = "focus right";  # Focus next tab (like hyprland changegroupactive f)
        cmd-shift-leftSquareBracket = "move left";   # Move tab left
        cmd-shift-rightSquareBracket = "move right"; # Move tab right
        cmd-1 = "workspace 1";
        cmd-2 = "workspace 2";
        cmd-3 = "workspace 3";
        cmd-4 = "workspace 4";
        cmd-5 = "workspace 5";
        cmd-6 = "workspace 6";
        cmd-7 = "workspace 7";
        cmd-8 = "workspace 8";
        cmd-9 = "workspace 9";
        cmd-0 = "workspace 10";
        cmd-shift-1 = "move-node-to-workspace 1";
        cmd-shift-2 = "move-node-to-workspace 2";
        cmd-shift-3 = "move-node-to-workspace 3";
        cmd-shift-4 = "move-node-to-workspace 4";
        cmd-shift-5 = "move-node-to-workspace 5";
        cmd-shift-6 = "move-node-to-workspace 6";
        cmd-shift-7 = "move-node-to-workspace 7";
        cmd-shift-8 = "move-node-to-workspace 8";
        cmd-shift-9 = "move-node-to-workspace 9";
        cmd-shift-0 = "move-node-to-workspace 10";
      };
    };
  };
}
