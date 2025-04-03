{ pkgs, lib, config, isDarwin, ... }: {

  options = {
    mine.cursor.enable = lib.mkEnableOption "Installs & configures cursor";
  };

  config = lib.mkIf config.mine.cursor.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ ./home.nix ];
    };
  } // (if isDarwin then {
    homebrew.casks = [ "cursor" ];
  } else { });
}
