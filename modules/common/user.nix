{ pkgs, config, lib, inputs, foo, ... }: {
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
    } // (if pkgs.stdenv.isDarwin then { } else { isNormalUser = true; });
  };
}
