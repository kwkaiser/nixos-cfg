{ pkgs, config, lib, inputs, isDarwin, ... }: {
  imports = (if isDarwin then [
    ./darwin
    ./common
    ./nix.nix
    ./user.nix
  ] else [
    ./nixos
    ./common
    ./nix.nix
    ./user.nix
  ]);

  # HM only modules
  home-manager.extraSpecialArgs = {
    inherit inputs;
    bconfig = config;
    isDarwin = isDarwin;
  };

  # home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.sharedModules =
    [ inputs.plasma-manager.homeModules.plasma-manager ];

  home-manager.users.${config.mine.username} = { imports = [ ./hm.nix ]; };
  home-manager.backupFileExtension = "backup";
}
