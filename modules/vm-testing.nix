{ mkModuleOption, ... }:
{
  options.nixos.modules.vm-testing = mkModuleOption { };

  config.nixos.modules.vm-testing = { config, lib, ... }: {
    options.mine.vmTesting = {
      memorySize = lib.mkOption { type = lib.types.int; };
      cores = lib.mkOption { type = lib.types.int; };
      diskSize = lib.mkOption { type = lib.types.nullOr lib.types.int; default = null; };
      forwardPorts = lib.mkOption { type = lib.types.listOf lib.types.attrs; default = [ ]; };
    };

    config.virtualisation.vmVariant = {
      virtualisation = {
        memorySize = config.mine.vmTesting.memorySize;
        cores = config.mine.vmTesting.cores;
        forwardPorts = config.mine.vmTesting.forwardPorts;
      } // lib.optionalAttrs (config.mine.vmTesting.diskSize != null) {
        diskSize = config.mine.vmTesting.diskSize;
      };
    };
  };
}
