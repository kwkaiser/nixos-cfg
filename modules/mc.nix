{ mkModuleOption, ... }:
let
  hmModule = { pkgs, lib, ... }: {
    home.packages = lib.optionals (!pkgs.stdenv.isDarwin) (with pkgs; [
      prismlauncher
    ]);
  };
in
{
  options.nixos.modules.mc = mkModuleOption { };
  options.darwin.modules.mc = mkModuleOption { };
  options.homeManager.modules.mc = mkModuleOption { };

  config.homeManager.modules.mc = hmModule;

  config.nixos.modules.mc = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
  };

  config.darwin.modules.mc = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
    # prismlauncher in nixpkgs uses extra-cmake-modules which is Linux-only;
    # use Homebrew cask on Darwin instead
    homebrew.casks = [ "prismlauncher" ];
  };
}
