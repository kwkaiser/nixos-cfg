{ config, lib, ... }: {
  options = {
    mine.firefox.enable = lib.mkEnableOption "Whether or not to use firefox";
  };

  config = lib.mkIf config.mine.firefox.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
