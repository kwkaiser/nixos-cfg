{ lib, config, ... }:
with lib; {
  options.mine.gtk.enable = mkEnableOption "GTK theme configuration";

  config = mkIf config.mine.gtk.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
