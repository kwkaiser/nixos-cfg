{ pkgs, lib, config, isDarwin, ... }: {
  options = {
    mine.steam.enable = lib.mkEnableOption "Enables steam gaming platform";
  };

  config = lib.mkIf config.mine.steam.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ ./home.nix ];
    };
  } // (if isDarwin then {
    homebrew.casks = [ "steam" ];
  } else { });
}

