{ pkgs, lib, config, ... }: {

  options = {
    mine.desktop.apps.waybar.enable =
      lib.mkEnableOption "Enables waybar as a statusbar";
  };

  config = lib.mkIf config.mine.desktop.apps.waybar.enable {
    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
