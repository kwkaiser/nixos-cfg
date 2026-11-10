{ mkModuleOption, ... }:
{
  options.darwin.modules.herdr-app = mkModuleOption { };

  config.darwin.modules.herdr-app = {
    homebrew.casks = [ "herdr-app" ];
  };
}
