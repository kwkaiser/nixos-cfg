{ pkgs, config, lib, inputs, ... }: {
  imports = [ ];

  # HM only modules
  home-manager.extraSpecialArgs = {
    inherit inputs;
    bconfig = config;
  };
  home-manager.users.${config.mine.username} = { imports = [ ./hm.nix ]; };
}
