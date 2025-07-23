{ pkgs, lib, config, isDarwin, ... }: {
  options = {
    mine.steam.enable = lib.mkEnableOption "Enables steam gaming platform";
  };

  config = lib.mkIf config.mine.steam.enable {
    #home-manager.users.${config.mine.username} = {
    #  imports = [ ./home.nix ];
    #};

    programs.steam = {
      enable = true;
      remotePlay.openFirewall =
        true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall =
        true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall =
        true; # Open ports in the firewall for Steam Local Network Game Transfers
    };

  } // (if isDarwin then { homebrew.casks = [ "steam" ]; } else { });
}

