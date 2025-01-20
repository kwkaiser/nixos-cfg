{ pkgs, lib, config, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  sysDep = {
    # xdg.portal.enable = true;
    # xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];

    # programs.hyprland.enable = true;
    environment.systemPackages = with pkgs;
      [
        # waybar
        # dunst
        # libnotify
        # swww
        kitty
        # rofi-wayland
      ];
  };
in {
  options = {
    mine.desktop.tiling.enable = lib.mkEnableOption "enables tiling desktop";
  };

  config = lib.mkIf config.mine.desktop.tiling.enable {
    # System config

    # Home manager config
    # home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  } // sysDep;
}
