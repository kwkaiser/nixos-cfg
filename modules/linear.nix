{ mkModuleOption, ... }:
{
  options.darwin.modules.linear = mkModuleOption { };

  config.darwin.modules.linear = {
    homebrew.casks = [ "linear-linear" ];
  };
}
