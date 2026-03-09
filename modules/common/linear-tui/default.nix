{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    mine.linear-tui.enable = lib.mkEnableOption "Whether or not to enable linear-tui";
  };

  config = lib.mkIf config.mine.linear-tui.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ ./home.nix ];
    };
  };
}
