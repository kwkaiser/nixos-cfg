{ pkgs, lib, config, ... }: {
  options = {
    mine.builder.enable = lib.mkEnableOption "Enables this host as a nix remote builder";

    mine.builder.publicKey = lib.mkOption {
      type = lib.types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJmeeD/NBdZPSs5Frh+jgmt0eHabG3d2F2s1pFtwsVj nix-remote-build-homelab-vps";
      description = "Public half of the dedicated remote-build keypair (private half lives in secretspec as NIX_BUILDER_KEY, installed on clients via `task install-nix-build-key`). Also referenced by client hosts' nix.buildMachines config.";
    };
  };

  config = lib.mkIf config.mine.builder.enable {
    users.groups.nixbuilder = { };

    users.users.nixbuilder = {
      isSystemUser = true;
      group = "nixbuilder";
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = [
        ''restrict,command="nix-store --serve --write" ${config.mine.builder.publicKey}''
      ];
    };

    nix.settings.trusted-users = [ "nixbuilder" ];

    nix.gc.options = lib.mkForce "--delete-older-than 1d";

    nix.settings.min-free = 5 * 1024 * 1024 * 1024;
    nix.settings.max-free = 20 * 1024 * 1024 * 1024;
  };
}
