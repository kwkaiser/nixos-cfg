{ pkgs, lib, config, ... }: {

  options = {
    mine.desktop.apps.kitty.enable =
      lib.mkEnableOption "Enables kitty as a used terminal";
  };

  config = lib.mkIf config.mine.desktop.apps.kitty.enable {
    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
