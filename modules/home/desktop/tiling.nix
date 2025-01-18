{ pkgs, lib, config, inputs, system, home, ... }: {
  options = {
    desktop.tiling.enable = lib.mkEnableOption "enables tiling desktop";
  };

  config = lib.mkIf config.desktop.tiling.enable {

    # home.packages = with pkgs; [ kitty wl-clipboard ];

    # wayland.windowManager.hyprland = {
    #   enable = true;
    #   package = inputs.hyprland.packages.${system}.hyprland;
    #   xwayland.enable = false;
    # };

    # wayland.windowManager.hyprland.settings = {
    #   "$mod" = "SUPER";
    #   "$terminal" = "kitty";
    #   disable_logs = false;
    #   bind = [ "$mod, ENTER, exec, $terminal" ] ++ (
    #     # workspaces
    #     # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
    #     builtins.concatLists (builtins.genList (i:
    #       let ws = i + 1;
    #       in [
    #         "$mod, code:1${toString i}, workspace, ${toString ws}"
    #         "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
    #       ]) 9));
    # };

    # wayland.windowManager.hyprland.extraConfig = ''
    #   debug:disable_logs = false
    # '';

    home.file.".config/hypr/hyprland.conf".source =
      config.lib.file.mkOutOfStoreSymlink ../../../dotfiles/hyprland.conf;
  };
}
