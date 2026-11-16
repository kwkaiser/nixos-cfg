{ mkModuleOption, ... }:
{
  options.darwin.modules.herdr-app = mkModuleOption { };

  config.darwin.modules.herdr-app =
    { pkgs, ... }:
    {
      homebrew.casks = [ "herdr-app" ];
      environment.systemPackages = [ pkgs.herdr-core ];
    };
}
