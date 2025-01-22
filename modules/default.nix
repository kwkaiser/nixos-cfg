{ pkgs, config, lib, inputs, ... }: {
  imports = [ ./shell ./nix.nix ./git ./user.nix ./desktop ./dev ./editor ];

  # HM only modules
  home-manager.extraSpecialArgs = {
    inherit inputs;
    bconfig = config;
  };
  home-manager.users.${config.mine.username} = { imports = [ ./hm.nix ]; };
}
