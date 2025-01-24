{ pkgs, lib, config, ... }: {
  options = {
    mine.desktop.tiling.enable = lib.mkEnableOption "enables tiling desktop";

    mine.desktop.tiling.monitor = lib.mkOption {
      type = lib.types.str;
      description = "Primary monitor";
    };
  };

  config = lib.mkIf config.mine.desktop.tiling.enable {
    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];

    programs.hyprland.enable = true;

    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
