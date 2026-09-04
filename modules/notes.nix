{ mkModuleOption, ... }:
let
  hmModule = { pkgs, ... }: { home.packages = with pkgs; [ obsidian ]; };
in
{
  options.nixos.modules.notes = mkModuleOption { };
  options.darwin.modules.notes = mkModuleOption { };
  options.homeManager.modules.notes = mkModuleOption { };

  config.homeManager.modules.notes = hmModule;

  config.nixos.modules.notes = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
  };

  config.darwin.modules.notes = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
    homebrew.casks = [
      "veracrypt"
      "macfuse"
    ];
  };
}
