{ pkgs, lib, config, ... }: {
  options = {
    desktop.tiling.enable = lib.mkEnableOption "enables tiling desktop";
  };

  config = lib.mkIf config.desktop.tiling.enable {
    environment.systemPackages = with pkgs; [
      waybar
      dunst
      libnotify
      swww
      kitty
      rofi-wayland
    ];

    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

  };
}
