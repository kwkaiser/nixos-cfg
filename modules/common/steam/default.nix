{ pkgs, lib, config, ... }: {

  options = {
    mine.steam.enable = lib.mkEnableOption "Enables steam gaming platform";
  };

  config = lib.mkIf config.mine.steam.enable {
    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}

