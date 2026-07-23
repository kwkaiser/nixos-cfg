{
  lib,
  config,
  ...
}:
{

  options = {
    mine.syncthing.enable = lib.mkEnableOption "Enables syncthing";
    mine.syncthing.peers = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      description = "Restrict which syncthing devices this host is allowed to know about and share folders with. null means all devices.";
    };
  };

  config = lib.mkIf config.mine.syncthing.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ (import ./home.nix { peers = config.mine.syncthing.peers; }) ];
    };
  };
}
