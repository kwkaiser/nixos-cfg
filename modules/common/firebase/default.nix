{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    mine.firebase.enable = lib.mkEnableOption "Whether or not to enable Firebase CLI";
  };

  config = lib.mkIf config.mine.firebase.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ ./home.nix ];
    };
  };
}
