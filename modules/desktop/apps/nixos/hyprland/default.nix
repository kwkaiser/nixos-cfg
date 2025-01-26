{ pkgs, lib, config, ... }: {

  options = {
    mine.desktop.apps.hyprland.enable =
      lib.mkEnableOption "Enables hyprland desktop";

  };

  config = lib.mkIf config.mine.desktop.apps.hyprland.enable {

    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];

    programs.hyprland.enable = true;

    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home ]; };
  };
}

