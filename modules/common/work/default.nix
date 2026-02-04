{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  options = {
    mine.work.enable = lib.mkEnableOption "Grab bag for misc work scripts / setup stuff";
  };

  config = lib.mkIf config.mine.work.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ ./home.nix ];
    };
  };
}
