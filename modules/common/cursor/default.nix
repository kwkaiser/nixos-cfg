{ pkgs, lib, config, ... }: {

  options = {
    mine.cursor.enable = lib.mkEnableOption "Installs & configures cursor";
  };

  config = lib.mkIf config.mine.cursor.enable {
    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
