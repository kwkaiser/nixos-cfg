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

    bind =
      [ "$mod, Return, exec, $terminal" "$mod, X, killactive" "$mod, M, exit" ];
  };

  # home.file.".config/hypr/hyprland.conf".source =
  #   config.lib.file.mkOutOfStoreSymlink ../../../dotfiles/hyprland.conf;
}
