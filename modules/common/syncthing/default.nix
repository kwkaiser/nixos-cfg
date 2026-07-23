{
  lib,
  config,
  ...
}:
{

  options = {
    mine.syncthing.enable = lib.mkEnableOption "Enables syncthing";
    mine.syncthing.deviceName = lib.mkOption {
      type = lib.types.str;
      description = "This host's syncthing device name. Determines which peers it's allowed to connect to, per the edges declared in ./home.nix.";
    };
  };

  config = lib.mkIf config.mine.syncthing.enable {
    home-manager.users.${config.mine.username} = {
      imports = [ (import ./home.nix { selfDevice = config.mine.syncthing.deviceName; }) ];
    };
  };
}
