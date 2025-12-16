{
  lib,
  config,
  isDarwin,
  ...
}:
{

  options = {
    mine.syncthing.enable = lib.mkEnableOption "Enables syncthing";
  };

  config = lib.mkIf config.mine.syncthing.enable (
    {

    }
    // lib.optionalAttrs isDarwin {
      homebrew.casks = [ "syncthing" ];
    }
    // lib.optionalAttrs (!isDarwin) {
      home-manager.users.${config.mine.username} = {
        imports = [ ./home.nix ];
      };
    }
  );
}
