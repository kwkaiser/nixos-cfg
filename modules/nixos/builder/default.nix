{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.mine.builder.enable {
    users.groups.${config.mine.builder.sshUser} = { };

    users.users.${config.mine.builder.sshUser} = {
      isSystemUser = true;
      group = config.mine.builder.sshUser;
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = [
        ''restrict,command="nix-daemon --stdio" ${config.mine.builder.publicKey}''
      ];
    };

    nix.settings.trusted-users = [ config.mine.builder.sshUser ];

    nix.gc.options = lib.mkForce "--delete-older-than 1d";

    nix.settings.min-free = 5 * 1024 * 1024 * 1024;
    nix.settings.max-free = 20 * 1024 * 1024 * 1024;
  };
}
