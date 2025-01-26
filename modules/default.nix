{ pkgs, config, lib, inputs, ... }: {
  imports = [ ./shell ./nix.nix ./git ./user.nix ./desktop ./dev ./editor ];
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
  };
  home-manager.users.${config.mine.username} = {
    # Attach nix-colors
    imports = [ inputs.nix-colors.homeManagerModules.default ./hm.nix ];
    colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;
  };
}
