{ mkModuleOption, ... }:
{
  options.nixos.modules.steam = mkModuleOption { };
  options.darwin.modules.steam = mkModuleOption { };

  config.nixos.modules.steam = {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession = {
        enable = true;
      };
    };
  };

  config.darwin.modules.steam = {
    homebrew.casks = [ "steam" ];
  };
}
