{ lib }:
{
  # Registers a home-manager-only feature identically under nixos.modules.<name>
  # and darwin.modules.<name> (both just splice homeManager.modules.<name> into
  # home-manager.users.<user>.imports), plus homeManager.modules.<name> itself.
  #
  # Deliberately a plain top-level function (imported directly, not injected
  # via _module.args): a module whose entire top-level shape comes from
  # *calling* a _module.args-provided function creates a genuine evaluation
  # cycle under flake-parts/import-tree, since collectStructuredModules must
  # call every top-level module to see if it has options/config/imports keys,
  # which would require resolving _module.args, which requires the module
  # list, which requires calling every module... A plain `lib`-only import
  # has no such dependency on the config fixpoint.
  mkHmFeature = name: hmModule: {
    options.nixos.modules.${name} = lib.mkOption { type = lib.types.deferredModule; };
    options.darwin.modules.${name} = lib.mkOption { type = lib.types.deferredModule; };
    options.homeManager.modules.${name} = lib.mkOption { type = lib.types.deferredModule; };

    config.nixos.modules.${name} = { config, ... }: {
      home-manager.users.${config.mine.username}.imports = [ hmModule ];
    };
    config.darwin.modules.${name} = { config, ... }: {
      home-manager.users.${config.mine.username}.imports = [ hmModule ];
    };
    config.homeManager.modules.${name} = hmModule;
  };
}
