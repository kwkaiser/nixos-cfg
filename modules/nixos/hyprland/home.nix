{ pkgs, lib, config, inputs, home, bconfig, ... }: {
  wayland.windowManager.hyprland.enable = true;
  services.dunst.enable = true;
  services.hyprpaper.enable = true;

  wayland.windowManager.hyprland.settings = {
    exec-once = "waybar";
    "$mod" = "SUPER";
    "$terminal" = "kitty";

    bind = [
      "$mod, Return, exec, $terminal"
      "$mod SHIFT, Q, killactive"
      "$mod SHIFT, E, exit"
      "$mod SHIFT, X, exec, hyprlock"
      # Navigation
      "$mod, h, movefocus, l"
      "$mod, l, movefocus, r"
      "$mod, j, movefocus, d"
      "$mod, k, movefocus, u"
      "$mod SHIFT, h, movewindow, l"
      "$mod SHIFT, l, movewindow, r"
      "$mod SHIFT, j, movewindow, d"
      "$mod SHIFT, k, movewindow, u"

      # Workspaces
    ] ++ (builtins.concatLists (builtins.genList (i:
      let _ = i + 1;
      in [
        "$mod, ${toString i}, workspace, ${toString i}"
        "$mod SHIFT, ${toString i}, movetoworkspace, ${toString i}"
      ]) 9)) ++ [
        "$mod, 0, workspace, 10"
      ]
      # Application launch keybinds
      ++ [ "$mod SHIFT, D, exec, rofi -show drun" ];

  };

  programs.hyprlock.enable = true;
  programs.hyprlock.settings = {
    general = {
      disable_loading_bar = true;
      hide_cursor = true;
      no_fade_in = false;
    };

    background = { color = "rgb(24, 25, 38)"; };

    input-field = {
      size = "200, 50";
      position = "0, -80";
      monitor = "";
      dots_center = true;
      fade_on_empty = false;
      font_color = "rgb(202, 211, 245)";
      inner_color = "rgb(91, 96, 120)";
      outer_color = "rgb(24, 25, 38)";
      outline_thickness = 5;
      placeholder_text = "Unlock:";
      shadow_passes = 2;
    };
  };
}
