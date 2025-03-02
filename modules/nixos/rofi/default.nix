{ pkgs, lib, config, ... }: {

  options = {
    mine.rofi.enable = lib.mkEnableOption "Enables rofi application launching";
  };

  config = lib.mkIf config.mine.rofi.enable {
    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}

