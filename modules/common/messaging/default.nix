{ pkgs, lib, config, ... }: {

  options = {
    mine.messaging.enable = lib.mkEnableOption "Enables messaging applications (Slack, Signal, Caprine, Discord)";
  };

  config = lib.mkIf config.mine.messaging.enable {
    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
} 