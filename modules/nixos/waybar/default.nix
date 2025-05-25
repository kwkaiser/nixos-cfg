{ pkgs, lib, config, ... }: {

  options = {
    mine.waybar.enable = lib.mkEnableOption "Enables waybar as a statusbar";

    mine.waybar.primaryMonitor = lib.mkOption {
      type = lib.types.str;
      description = "Primary monitor for waybar";
    };

    mine.waybar.secondaryMonitor = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional secondary monitor for waybar";
    };
  };

  config = lib.mkIf config.mine.waybar.enable {
    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
