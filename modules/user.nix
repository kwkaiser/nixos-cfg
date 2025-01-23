{ pkgs, config, lib, inputs, ... }: {
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

    mine.primarySshKey = lib.mkOption {
      type = lib.types.str;
      description = "Default SSH associated with that user";
    };
  };

  config = {
    # Conditionally include user properties if not on darwin
    users.users.${config.mine.username} = {
      home = builtins.toPath "${config.mine.homeDir}";
      description = "Primary user";
      openssh.authorizedKeys.keys = [ config.mine.primarySshKey ];
    } // (if pkgs.stdenv.isDarwin then
      { }
    else {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      initialPassword = "bingus";
    });
  };
}
