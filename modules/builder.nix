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

      # min-free needs real headroom above k3s's kubelet ephemeral-storage
      # eviction threshold (~5% of disk, ~3.7GiB here) or a fast burst of
      # remote-build traffic can blow past both before nix's 5s-interval
      # auto-GC check can react and free space in time.
      nix.settings.min-free = 10 * 1024 * 1024 * 1024;
      nix.settings.max-free = 20 * 1024 * 1024 * 1024;
    };
}
