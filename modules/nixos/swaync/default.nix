{ pkgs, config, lib, ... }: {
  options = {
    mine.swaync.enable =
      lib.mkEnableOption "Whether or not to enable swaync notification daemon";
  };

  config = lib.mkIf config.mine.swaync.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
