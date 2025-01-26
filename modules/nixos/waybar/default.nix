{ pkgs, lib, config, ... }: {

  options = {
    mine.waybar.enable = lib.mkEnableOption "Enables waybar as a statusbar";

    mine.waybar.monitor = lib.mkOption {
      type = lib.types.str;
      description = "Primary monitor";
    };
  };

  config = lib.mkIf config.mine.desktop.apps.waybar.enable {
    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
