{ pkgs, lib, config, ... }: {

  options = {
    mine.hyprland.enable = lib.mkEnableOption "Enables hyprland desktop";
  };

  config = lib.mkIf config.mine.hyprland.enable {
    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
    programs.hyprland.enable = true;
    security.pam.services.hyprlock = { };

    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}

