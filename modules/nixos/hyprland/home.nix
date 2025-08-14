{ pkgs, lib, config, inputs, home, bconfig, ... }: {
  home.packages = with pkgs; [
    swww
    jq
    bibata-cursors
    xfce.thunar
    sway-contrib.grimshot
  ];

  imports = [ ./scripts.nix ];

  wayland.windowManager.hyprland.enable = true;

  services.gammastep = {
    enable = true;
    latitude = 42.35;
    longitude = -71.05;
  };

  home.pointerCursor = {
    name =
      "Bibata-Modern-Classic"; # or "Adwaita", "phinger-cursors-light", etc.
    package = pkgs.bibata-cursors; # match the package
    size = 24;
    gtk.enable = true; # applies to GTK apps too
    x11.enable = true; # enables for XWayland too
  };

  wayland.windowManager.hyprland.settings = {
    monitor =
      [ "DP-2,1920x1080@144,0x0,1,transform,1" "DP-1,1920x1080@144,1080x0,1" ];

    # Workspace assignments
    workspace = [
      # Workspaces 1-5 on left monitor (DP-1)
      "1, monitor:DP-2"
      "2, monitor:DP-2"
      "3, monitor:DP-2"
      "4, monitor:DP-2"
      "5, monitor:DP-2"
      # Workspaces 6-10 on right monitor (DP-2)
      "6, monitor:DP-1"
      "7, monitor:DP-1"
      "8, monitor:DP-1"
      "9, monitor:DP-1"
      "10, monitor:DP-1"
    ];

    exec-once = [
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "waybar &"
      "swaync &"
      "sleep 1 && swww-daemon &"
    ];
    "$mod" = "SUPER";
    "$terminal" = "kitty";

    bind = [
      "$mod, Return, exec, $terminal"
      "$mod SHIFT, Q, killactive"
      "$mod SHIFT, E, exit"
      "$mod SHIFT, X, exec, hyprlock"
      "$mod, f, fullscreen"
      "$mod SHIFT, R, exec, hyprctl reload"
      "$mod, m, exec, shiftTabLeft"

      # Screenshots
      "$mod SHIFT, C, exec, grimshot save area ~/Documents/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
      "$mod, c, exec, grimshot copy area"

      # Navigation
      "$mod, h, movefocus, l"
      "$mod, l, movefocus, r"
      "$mod, j, movefocus, d"
      "$mod, k, movefocus, u"
      "$mod SHIFT, h, movewindow, l"
      "$mod SHIFT, l, movewindow, r"
      "$mod SHIFT, j, movewindow, d"
      "$mod SHIFT, k, movewindow, u"

      # Layout management (similar to sway)
      "$mod, w, exec, hyprctl dispatch layoutmsg orientationtop" # Set tabbed layout
      "$mod, s, togglegroup" # Create/toggle group (stacked/tabbed container)
      "$mod, e, moveoutofgroup" # Exit group mode back to normal tiling
      "$mod, v, exec, hyprctl dispatch layoutmsg orientationbottom" # Split vertically
      "$mod SHIFT, v, exec, hyprctl dispatch layoutmsg orientationright" # Split horizontally

      # Tabbing
      "$mod, bracketleft, changegroupactive, b"
      "$mod, bracketright, changegroupactive, f"
      "$mod SHIFT, bracketleft, exec, shiftTabLeft"
      "$mod SHIFT, bracketright, exec, shiftTabRight"

      # Notifications
      "$mod SHIFT, b, exec, swaync-client -C"
      "$mod SHIFT, n, exec, swaync-client -t"
      "$mod, n, exec, swaync-client --close-latest"

      # Audio
      "$mod, code:96, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      "$mod, code:95, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      "$mod, code:76, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

      "$mod SHIFT, code:96, exec, playerctl next"
      "$mod SHIFT, code:95, exec, playerctl play-pause"
      "$mod SHIFT, code:76, exec, playerctl previous"

      # Workspaces
    ] ++ (builtins.concatLists (builtins.genList (i:
      let ws = i + 1;
      in [
        "$mod, ${toString ws}, workspace, ${toString ws}"
        "$mod SHIFT, ${toString ws}, movetoworkspace, ${toString ws}"
      ]) 9)) ++ [
        "$mod, 0, workspace, 10"
      ]
      # Application launch keybinds
      ++ [
        "$mod, D, exec, sh -c 'ACTIVE_MONITOR=$(hyprctl monitors -j | jq -r \".[] | select(.focused == true) | .name\"); MONITOR_FLAG=\"\"; if [ \"$ACTIVE_MONITOR\" = \"DP-2\" ]; then MONITOR_FLAG=\"-monitor 0\"; else MONITOR_FLAG=\"-monitor 1\"; fi; SELECTION=$(hyprctl clients -j | jq -r \".[] | select(.workspace.id != -99) | .title\" | rofi -dmenu -i -p \"Window\" $MONITOR_FLAG); if [ -n \"$SELECTION\" ]; then ADDRESS=$(hyprctl clients -j | jq -r \".[] | select(.title == \\\"$SELECTION\\\") | .address\" | head -1); hyprctl dispatch focuswindow address:\"$ADDRESS\"; fi'"
        "$mod SHIFT, D, exec, sh -c 'ACTIVE_MONITOR=$(hyprctl monitors -j | jq -r \".[] | select(.focused == true) | .name\"); if [ \"$ACTIVE_MONITOR\" = \"DP-2\" ]; then rofi -show drun -monitor 0; else rofi -show drun -monitor 1; fi'"
      ];

    group = {
      groupbar = {
        enabled = true;
        font_size = 12;
        height = 18;
        render_titles = true;
        scrolling = true;
      };
    };

    animations = {
      enabled = true;

      bezier = [
        "wind, 0.05, 0.9, 0.1, 1.05"
        "winIn, 0.1, 1.1, 0.1, 1.1"
        "winOut, 0.3, -0.3, 0, 1"
        "liner, 1, 1, 1, 1"
      ];

      animation = [
        "windows, 1, 3, wind, slide" # Reduced from ~6-7 to 3
        "windowsIn, 1, 3, winIn, slide" # Reduced from ~6-7 to 3
        "windowsOut, 1, 2, winOut, slide" # Reduced from ~4-5 to 2
        "windowsMove, 1, 3, wind, slide" # Reduced from ~6-7 to 3
        "border, 1, 1, liner" # Reduced from ~10 to 1
        "borderangle, 1, 4, liner" # Reduced from ~8 to 4
        "fade, 1, 5, default" # Reduced from ~10 to 5
        "workspaces, 1, 3, wind" # Reduced from ~6 to 3
      ];
    };

  };

  programs.hyprlock.enable = true;
  programs.hyprlock.settings = {
    general = {
      disable_loading_bar = true;
      hide_cursor = true;
      no_fade_in = false;
    };

    input-field = {
      size = "200, 50";
      position = "0, -80";
      monitor = "";
      dots_center = true;
      fade_on_empty = false;
      outline_thickness = 5;
      placeholder_text = "Unlock:";
      shadow_passes = 2;
    };
  };
}
