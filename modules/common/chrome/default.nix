{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.chrome.enable = lib.mkEnableOption "Whether or not to use chrome";
  };

  config = lib.mkIf config.mine.chrome.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
