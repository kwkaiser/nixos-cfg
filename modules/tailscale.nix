{ mkModuleOption, ... }:
let
  hmModule = { pkgs, ... }: {
    home.packages = with pkgs; [
      tailcat
    ];
  };
in
{
  options.nixos.modules.tailscale = mkModuleOption { };
  options.darwin.modules.tailscale = mkModuleOption { };
  options.homeManager.modules.tailscale = mkModuleOption { };

  config.homeManager.modules.tailscale = hmModule;

  config.nixos.modules.tailscale = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
    services.tailscale.enable = true;
  };

  config.darwin.modules.tailscale = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
    services.tailscale.enable = true;
  };
}
