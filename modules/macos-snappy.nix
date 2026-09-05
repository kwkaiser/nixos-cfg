{ mkModuleOption, ... }:
{
  options.darwin.modules.macos-snappy = mkModuleOption { };

  config.darwin.modules.macos-snappy = { ... }: {
    system.defaults.NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;

    system.defaults.dock.autohide-delay = 0.0;
    system.defaults.dock.autohide-time-modifier = 0.0;
    system.defaults.dock.launchanim = false;
    system.defaults.dock.expose-animation-duration = 0.0;
  };
}
