{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  options = {
    mine.tmux.enable = lib.mkEnableOption "Whether or not to enable tmux";
  };

  config = lib.mkIf config.mine.tmux.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ ./home.nix ];
    };
  };
}
