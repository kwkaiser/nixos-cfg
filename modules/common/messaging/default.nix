{ pkgs, lib, config, isDarwin, ... }: {

  options = {
    mine.messaging.enable = lib.mkEnableOption
      "Enables messaging applications (Slack, Signal, Caprine, Discord)";
  };

  config = lib.mkIf config.mine.messaging.enable (lib.mkMerge [
    {
      home-manager.users.${config.mine.username} = {
        imports = [ ./home.nix ];
      };
    }
    # For KDE connect
    (lib.mkIf (!isDarwin) {
      networking.firewall = rec {
        allowedTCPPortRanges = [{
          from = 1714;
          to = 1764;
        }];
        allowedUDPPortRanges = allowedTCPPortRanges;
      };
    })
  ]);
}
