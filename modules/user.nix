{ pkgs, config, lib, inputs, isDarwin, ... }: {
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
    security.sudo.extraConfig = ''
      ${config.mine.username} ALL=(ALL) NOPASSWD: ALL
    '';

  } // (if isDarwin then {
    system.primaryUser = config.mine.username;
    users.users.${config.mine.username} = {
      description = "Primary user";
      openssh.authorizedKeys.keys = [ config.mine.primarySshKey ];
      extraGroups = [ "wheel" "networkmanager" ];
    };
  } else { 
    users.users.root.password = "bingus";
    users.users.${config.mine.username} = {
      isNormalUser = true;
      description = "Primary user";
      home = builtins.toPath "${config.mine.homeDir}";
      openssh.authorizedKeys.keys = [ config.mine.primarySshKey ];
      extraGroups = [ "wheel" "networkmanager" ];
      initialPassword = "bingus";
    };
  });
}
