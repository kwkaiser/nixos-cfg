{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    mine.flyio.enable = lib.mkEnableOption "Whether or not to enable the Fly.io CLI";
  };

  config = lib.mkIf config.mine.flyio.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ ./home.nix ];
    };
  };
}
