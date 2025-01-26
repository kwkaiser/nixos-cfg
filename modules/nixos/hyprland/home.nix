{ pkgs, lib, config, inputs, home, bconfig, ... }: {

  wayland.windowManager.hyprland.enable = true;
  services.dunst.enable = true;
  services.hyprpaper.enable = true;
  programs.rofi.enable = true;

  wayland.windowManager.hyprland.settings = {
    exec-once = "waybar";
    "$mod" = "SUPER";
    "$terminal" = "kitty";

    bind = [
      "$mod, Return, exec, $terminal"
      "$mod SHIFT, Q, killactive"
      "$mod SHIFT, E, exit"
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

}
