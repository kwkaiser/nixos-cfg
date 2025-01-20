{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.desktop.screenDimmer.enable =
      lib.mkEnableOption "Whether or not to enable screen dimming services";
  };

  config = lib.mkIf config.mine.desktop.screenDimmer.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./hm.nix ]; };
  };
}
