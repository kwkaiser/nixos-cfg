{ pkgs, lib, config, inputs, home, ... }: {

  home.packages = with pkgs; [ kitty gtk3 ];

  wayland.windowManager.hyprland.enable = true;
  services.dunst.enable = true;
  services.hyprpaper.enable = true;
  programs.waybar.enable = true;
  programs.rofi.enable = true;

  home.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    KITTY_DISABLE_WAYLAND = "0";
  };

  wayland.windowManager.hyprland.settings = {
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
