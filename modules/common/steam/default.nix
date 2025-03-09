{ pkgs, lib, config, isDarwin, ... }: {

  options = {
    mine.steam.enable = lib.mkEnableOption "Enables steam gaming platform";
  };

  config = lib.mkIf config.mine.steam.enable (lib.mkMerge [
    {
      home-manager.users.${config.mine.username} = {
        imports = [ ./home.nix ];
      };
    }

    (lib.mkIf isDarwin { homebrew.casks = [ "steam" ]; })
  ]);
}

