{ pkgs, lib, config, inputs, home, bconfig, ... }: {

  home.packages = with pkgs; [ kitty gtk3 xorg.xrandr ];

  wayland.windowManager.hyprland.enable = true;
  services.dunst.enable = true;
  services.hyprpaper.enable = true;
  programs.rofi.enable = true;

  programs.waybar = {
    enable = true;
    settings = {
      topBar = {
        output = [ bconfig.mine.desktop.tiling.monitor ];
        layer = "top";
        position = "top";
        height = 30;

        modules-center = [ "hyprland/workspaces" ];
        "hyprland/workspaces" = { on-click = "activate"; };
      };
      bottomBar = {
        output = [ bconfig.mine.desktop.tiling.monitor ];
        layer = "top";
        position = "bottom";
        height = 30;

        modules-left = [ "cpu" ];
        modules-center = [ "clock" ];
        modules-right = [ "memory" ];

        cpu = {
          interval = 10;
          format = " {}%";
        };
        clock = {
          interval = 1;
          format = "{:%H:%M:%S}";
        };
        memory = {
          interval = 30;
          format = "{}%";
          max-length = 10;
        };
      };
    };
  };
  home.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    KITTY_DISABLE_WAYLAND = "0";
  };

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

  # home.file.".config/hypr/hyprland.conf".source =
  #   config.lib.file.mkOutOfStoreSymlink ../../../dotfiles/hyprland.conf;
}
