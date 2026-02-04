{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  options = {
    mine.claude.enable = lib.mkEnableOption "Whether or not to enable claude code";
  };

  config = lib.mkIf config.mine.claude.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ ./home.nix ];
    };
  };
}
