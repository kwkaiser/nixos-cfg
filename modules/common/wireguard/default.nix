{
  lib,
  config,
  ...
}:
{
  options = {
    mine.wireguard.enable = lib.mkEnableOption "WireGuard client tools (peer, not an instance)";
  };

  config = lib.mkIf config.mine.wireguard.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ ./home.nix ];
    };
  };
}
