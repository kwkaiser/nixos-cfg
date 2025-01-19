{ pkgs, config, lib, inputs, archi, commonArgs, ... }: {
  options = {
    bingus.username = lib.mkEnableOption "Username for the primary user";
    bingus.homeDir = lib.mkEnableOption "Home directory for the primary user";
  };

  # HM only modules
  home-manager.users.${commonArgs.primaryUser} = { imports = [ ./hm.nix ]; };

  # Other modules
  imports = [ ./shell ];

}
