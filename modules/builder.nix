{ mkModuleOption, ... }:
{
  # Nixos-only: the actual "act as the remote builder" role (creates the
  # nixbuilder system user etc). mine.builder.{hostName,sshUser,publicKey} and
  # mine.isBuilder are declared in ./nix-settings.nix instead, since every
  # host (including darwin clients that never import this module) needs them
  # to compute its own remote-build client config.
  options.nixos.modules.builder = mkModuleOption { };

  config.nixos.modules.builder =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
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
