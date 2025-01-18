{ pkgs, lib, config, inputs, system, ... }: {
  options = {
    desktop.tiling.enable = lib.mkEnableOption "enables tiling desktop";
  };

  config = lib.mkIf config.desktop.tiling.enable {

    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${system}.hyprland;
    };

    # home.file.".config/hypr/hyprland.conf".source =
    #   config.lib.file.mkOutOfStoreSymlink ../../../dotfiles/hyprland.conf;
  };
}
