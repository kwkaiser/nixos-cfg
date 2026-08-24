{
  lib,
  config,
  ...
}:
{
  options = {
    mine.borgmatic.enable = lib.mkEnableOption "borg and borgmatic CLI tools";
  };

  config = lib.mkIf config.mine.borgmatic.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ ./home.nix ];
    };
  };
}
