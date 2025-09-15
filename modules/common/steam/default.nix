{ pkgs, lib, config, isDarwin, ... }: {
  options = {
    mine.steam.enable = lib.mkEnableOption "Enables steam gaming platform";
  };

  config = lib.mkIf config.mine.steam.enable (if isDarwin then {
    homebrew.casks = [ "steam" ];
  } else {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession = { enable = true; };
    };
  });
}

