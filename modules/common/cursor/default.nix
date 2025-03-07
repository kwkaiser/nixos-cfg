{ pkgs, lib, config, isDarwin, ... }: {

  options = {
    mine.cursor.enable = lib.mkEnableOption "Installs & configures cursor";
  };

  config = lib.mkIf config.mine.cursor.enable (lib.mkMerge [
    {
      home-manager.users.${config.mine.username} = {
        imports = [ ./home.nix ];
      };
    }

    (lib.mkIf isDarwin { homebrew.casks = [ "cursor" ]; })
  ]);
}
