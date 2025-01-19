{ pkgs, config, lib, inputs, ... }: {
  # Other modules
  imports = [ ./shell ];

  options = {
    bingus.username = lib.mkOption {
      type = lib.types.str;
      description = "Username for the primary user";
    };

    bingus.homeDir = lib.mkOption {
      type = lib.types.str;
      description = "Home directory for the primary user";
    };
  };

  config = {
    users.users.${config.bingus.username} = {
      home = builtins.toPath "${config.bingus.homeDir}";
      description = "Primary user";
    };

    # HM only modules
    home-manager.users.${config.bingus.username} = { imports = [ ./hm.nix ]; };
  };
}
