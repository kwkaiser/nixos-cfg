{ mkModuleOption, ... }:
let
  hmModule = { pkgs, ... }: {
    home.packages = [
      pkgs.rusty-path-of-building
    ];
  };
in
{
  options.nixos.modules.pathofbuilding = mkModuleOption { };

  config.nixos.modules.pathofbuilding = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
  };
}
