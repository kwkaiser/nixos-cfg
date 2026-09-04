{ mkModuleOption, ... }:
let
  hmModule = { pkgs, ... }: {
    home.packages = with pkgs; [
      docker-compose
    ];
  };
in
{
  options.nixos.modules.docker = mkModuleOption { };
  options.darwin.modules.docker = mkModuleOption { };
  options.homeManager.modules.docker = mkModuleOption { };

  config.homeManager.modules.docker = hmModule;

  config.nixos.modules.docker = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
    virtualisation.docker = {
      enable = true;
      daemon.settings = {
        log-driver = "json-file";
      };
    };
    users.users.${config.mine.username}.extraGroups = [ "docker" ];
  };

  config.darwin.modules.docker = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
    homebrew.casks = [ "docker" ];
  };
}
