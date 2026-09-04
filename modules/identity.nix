{ mkModuleOption, ... }:
let
  email = "karl@kwkaiser.io";
  sshKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSHiO1udAkk/aq6l5Gojw1GWmz/2vDl/JMTot8VgaOgXyDBMRdQZw7HpyeNNY0DZszLi9u9cr2aG57H6yhId7C9PQiH75KZUsJYIpbNzRuetrXIpPBCccERB1L456P3X6Yo9N65pMAOSaL1YHkNP1a4TL3/qatm284u31hUBKq4/+t+D1U4uhG2RqT0bTgpzDW6zvHFDhR4Knnqon/2NX8+Hpv9jb0k9zMh16RBXrnMTbOEoXegdtrHZf91xIdZaOeQ20dnJv19bUJDP1m0Ynxr1XVZnHrD+bO1hohA+1tkcrfX+EVBDM5872oa4Ek8GQZIZoazqzjcdd6+/tHJM2yG66dlttPtfe/UaPo2JTiXqIaUubYdpQ+7kwWNOX605QT10mhIP3EG8/bxmM7p5CnsMXC5oG5jDcsMu8GlXtBweAXa9FvCBMQq/aVaC3HKIW1QABBlLxp9hxLeG45ptPaNSJG5MAlcrHXNAQvLJvv5pjs55K8FXO2s9smsOqXnLM= (encrypted)";
in
{
  options.nixos.modules.identity = mkModuleOption { };
  options.darwin.modules.identity = mkModuleOption { };

  config.nixos.modules.identity = { config, lib, ... }: {
    options.mine = {
      username = lib.mkOption { type = lib.types.str; default = "kwkaiser"; description = "Username for the primary user"; };
      homeDir = lib.mkOption { type = lib.types.str; default = "/home/${config.mine.username}"; description = "Home directory for the primary user"; };
      email = lib.mkOption { type = lib.types.str; default = email; description = "Default email associated with that user"; };
      primarySshKey = lib.mkOption { type = lib.types.str; default = sshKey; description = "Default SSH key associated with that user"; };
    };

    config = {
      security.sudo.extraConfig = ''
        ${config.mine.username} ALL=(ALL) NOPASSWD: ALL
      '';
      users.users.root.password = "bingus";
      users.users.${config.mine.username} = {
        isNormalUser = true;
        description = "Primary user";
        home = builtins.toPath config.mine.homeDir;
        openssh.authorizedKeys.keys = [ config.mine.primarySshKey ];
        extraGroups = [ "wheel" "networkmanager" ];
        initialPassword = "bingus";
      };
    };
  };

  config.darwin.modules.identity = { config, lib, ... }: {
    options.mine = {
      username = lib.mkOption { type = lib.types.str; default = "karl"; description = "Username for the primary user"; };
      homeDir = lib.mkOption { type = lib.types.str; default = "/Users/${config.mine.username}"; description = "Home directory for the primary user"; };
      email = lib.mkOption { type = lib.types.str; default = email; description = "Default email associated with that user"; };
      primarySshKey = lib.mkOption { type = lib.types.str; default = sshKey; description = "Default SSH key associated with that user"; };
    };

    config = {
      security.sudo.extraConfig = ''
        ${config.mine.username} ALL=(ALL) NOPASSWD: ALL
      '';
      system.primaryUser = config.mine.username;
      users.users.${config.mine.username} = {
        description = "Primary user";
        openssh.authorizedKeys.keys = [ config.mine.primarySshKey ];
        home = builtins.toPath config.mine.homeDir;
      };
    };
  };
}
