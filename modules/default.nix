{ pkgs, config, lib, inputs, ... }:
let isDarwin = pkgs.stdenv.isDarwin;
in {
  # Exclude certain modules
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
    # Conditionally include isNormalUser if not in darwin
    users.users.${config.mine.username} = {
      home = builtins.toPath "${config.mine.homeDir}";
      description = "Primary user";
    } // (if isDarwin then { } else { isNormalUser = true; });

    # HM only modules
    home-manager.extraSpecialArgs = {
      inherit inputs;
      bconfig = config;
    };
    home-manager.users.${config.mine.username} = { imports = [ ./hm.nix ]; };
  };
}
