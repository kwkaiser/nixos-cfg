{ mkModuleOption, ... }:
let
  hmModule = { pkgs, ... }: {
    home.packages =
      with pkgs;
      pkgs.lib.optionals (!pkgs.stdenv.isDarwin) [ keepassxc ]
      ++ [
        _1password-cli
        _1password-gui
      ];
  };
in
{
  options.nixos.modules.keepass = mkModuleOption { };
  options.darwin.modules.keepass = mkModuleOption { };
  options.homeManager.modules.keepass = mkModuleOption { };

  config.homeManager.modules.keepass = hmModule;

  config.nixos.modules.keepass = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
  };

  config.darwin.modules.keepass = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
    # keepassxc in nixpkgs pulls in extra-cmake-modules which is Linux-only;
    # use Homebrew cask on Darwin instead
    homebrew.casks = [ "keepassxc" ];
  };
}
