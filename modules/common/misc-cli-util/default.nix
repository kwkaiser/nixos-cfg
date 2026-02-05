{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  options = {
    mine.misc-cli-util.enable = lib.mkEnableOption "Whether or not to enable misc cli util scripts";
  };

  config = lib.mkIf config.mine.misc-cli-util.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ ./home.nix ];
    };
  };
}
