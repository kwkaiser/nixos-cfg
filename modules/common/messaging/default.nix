{ pkgs, lib, config, isDarwin, ... }: {

  options = {
    mine.messaging.enable = lib.mkEnableOption
      "Enables messaging applications (Slack, Signal, Caprine, Discord)";
  };

  config = lib.mkIf config.mine.messaging.enable {
    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };

    networking.firewall = rec {
      allowedTCPPortRanges = [{
        from = 1714;
        to = 1764;
      }];
      allowedUDPPortRanges = allowedTCPPortRanges;
    };

  } // (if isDarwin then {
    homebrew.casks = [ "slack" "signal" "caprine" "discord" ];
  } else
    { });
}
