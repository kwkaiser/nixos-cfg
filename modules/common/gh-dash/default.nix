{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    mine.gh-dash.enable = lib.mkEnableOption "Whether or not to enable gh-dash and related tools";
  };

  config = lib.mkIf config.mine.gh-dash.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ ./home.nix ];
    };
  };
}
