{ mkModuleOption, ... }:
let
  systemModule = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ chromium terraform ];
  };
in
{
  options.nixos.modules.chrome = mkModuleOption { };
  options.darwin.modules.chrome = mkModuleOption { };

  config.nixos.modules.chrome = systemModule;
  config.darwin.modules.chrome = systemModule;
}
