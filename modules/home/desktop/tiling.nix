{ pkgs, lib, config, ... }: {
  options = {
    desktop.tiling.enable = lib.mkEnableOption "enables tiling desktop";
  };

  config = lib.mkIf config.desktop.tiling.enable {

    home.file.".config/hypr/hyprland.conf".source =
      config.lib.file.mkOutOfStoreSymlink ../../../dotfiles/hyprland.conf;
  };
}
