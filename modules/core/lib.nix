{ lib, ... }:
{
  config._module.args.mkModuleOption =
    args: lib.mkOption ({ type = lib.types.deferredModule; } // args);
}
