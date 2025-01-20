{ pkgs, config, lib, inputs, ... }: {
  imports = [ ./shell ./nix.nix ./git ./desktop ];

  options = {
    mine.username = lib.mkOption {
      type = lib.types.str;
      description = "Username for the primary user";
    };

    mine.homeDir = lib.mkOption {
      type = lib.types.str;
      description = "Home directory for the primary user";
    };

    mine.email = lib.mkOption {
      type = lib.types.str;
      description = "Default email associated with that user";
    };
  };

  config = {
    users.users.${config.mine.username} = {
      home = builtins.toPath "${config.mine.homeDir}";
      description = "Primary user";
    };

    # HM only modules

    home-manager.extraSpecialArgs = {
      inherit inputs;
      bconfig = config;
    };
    home-manager.users.${config.mine.username} = { imports = [ ./hm.nix ]; };
  };
}
