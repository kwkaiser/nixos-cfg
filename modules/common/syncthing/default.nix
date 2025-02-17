{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.syncthing.enable =
      lib.mkEnableOption "Whether or not to use syncthing";
  };

  config = lib.mkIf config.mine.syncthing.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
