{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    mine.codex.enable = lib.mkEnableOption "Whether or not to enable OpenAI Codex CLI";
  };

  config = lib.mkIf config.mine.codex.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ ./home.nix ];
    };
  };
}
