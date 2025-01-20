{ pkgs, lib, config, ... }: {
  options = {
    mine.desktop.tiling.enable = lib.mkEnableOption "enables tiling desktop";
  };

  config = lib.mkIf config.mine.desktop.tiling.enable {
    # System config
    environment.systemPackages = with pkgs; [
      waybar
      dunst
      libnotify
      swww
      kitty
      rofi-wayland
    ];

    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];

    programs.hyprland.enable = true;

    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
