{ pkgs, lib, config, ... }: {

  options = {
    mine.gthumb.enable = lib.mkEnableOption "Enables gthumb image browser";
  };

  config = lib.mkIf config.mine.gthumb.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
