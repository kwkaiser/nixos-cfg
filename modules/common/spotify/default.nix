{ pkgs, lib, config, isDarwin, ... }: {
  options = {
    mine.spotify.enable =
      lib.mkEnableOption "Enables spotify music streaming service";
  };

  config = lib.mkIf config.mine.spotify.enable (if isDarwin then {
    homebrew.casks = [ "spotify" ];
  } else {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  });
}
