{ mkModuleOption, ... }:
{
  options.darwin.modules.sikarugir = mkModuleOption { };

  config.darwin.modules.sikarugir = {
    homebrew.taps = [ "Sikarugir-App/sikarugir" ];
    homebrew.casks = [ "Sikarugir-App/sikarugir/sikarugir" ];
  };
}
