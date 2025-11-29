{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    mine.spotify.enable = lib.mkEnableOption "Enables spotify music streaming service";
  };

  config = lib.mkIf config.mine.spotify.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ ./home.nix ];
    };
  };
}
