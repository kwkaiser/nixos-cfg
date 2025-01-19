{ pkgs, config, lib, inputs, archi, commonArgs, ... }: {
  # HM only modules
  home-manager.users.${commonArgs.primaryUser} = { imports = [ ./hm.nix ]; };

  # Other modules
  imports = [ ./shell ];

}
