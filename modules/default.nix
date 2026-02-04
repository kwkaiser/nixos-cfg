{
  pkgs,
  config,
  lib,
  inputs,
  isDarwin,
  ...
}:
{
  imports = (
    if isDarwin then
      [
        ./darwin
        ./common
        ./user.nix
      ]
    else
      [
        ./nixos
        ./common
        ./user.nix
      ]
  );

  home-manager.extraSpecialArgs = {
    inherit inputs;
    bconfig = config;
    isDarwin = isDarwin;
  };

  home-manager.useUserPackages = true;
  home-manager.sharedModules = [
    inputs.plasma-manager.homeModules.plasma-manager
    inputs.stylix.homeModules.stylix
    inputs.nvf.homeManagerModules.default
  ];

  home-manager.users.${config.mine.username} = {
    imports = [ ./hm.nix ];
  };
  home-manager.backupFileExtension = "backup";
}
