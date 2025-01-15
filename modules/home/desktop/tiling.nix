{ pkgs, lib, config, ... }: {
  options = {
    desktop.tiling.enable = lib.mkEnableOption "enables tiling desktop";
  };

  config = lib.mkIf config.desktop.tiling.enable {
    home.file.".config/hypr/hyprland.conf".source =
      "../../../../dotfiles/hyprland.conf";
  };
}
