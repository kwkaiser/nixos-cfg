{ pkgs, lib, config, isDarwin, ... }: {

  options = { mine.syncthing.enable = lib.mkEnableOption "Enables syncthing"; };

  config = lib.mkIf config.mine.syncthing.enable ({ } // (if isDarwin then {
    homebrew.casks = [ "syncthing" ];
  } else {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  }));
}
