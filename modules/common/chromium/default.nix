{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.chromium.enable = lib.mkEnableOption "Whether or not to use chromium";
  };

  config = lib.mkIf config.mine.chromium.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
