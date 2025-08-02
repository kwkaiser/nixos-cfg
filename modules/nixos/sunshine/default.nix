{ pkgs, lib, config, ... }: {

  options = { mine.rofi.enable = lib.mkEnableOption "Enables sunshine"; };

  config = lib.mkIf config.mine.sunshine.enable {

    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
    }
    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };

  };
}

