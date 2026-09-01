{ lib, ... }: {
  options = {
    mine.builder.enable = lib.mkEnableOption "Marks this host as the nix remote builder (server role)";

    mine.builder.hostName = lib.mkOption {
      type = lib.types.str;
      default = "kwkaiser.io";
      description = "SSH hostname clients use to reach the nix remote builder.";
    };

    mine.builder.sshUser = lib.mkOption {
      type = lib.types.str;
      default = "nixbuilder";
      description = "SSH user clients connect as to reach the nix remote builder.";
    };

    mine.builder.publicKey = lib.mkOption {
      type = lib.types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJmeeD/NBdZPSs5Frh+jgmt0eHabG3d2F2s1pFtwsVj nix-remote-build-homelab-vps";
      description = "Public half of the dedicated remote-build keypair (private half lives in secretspec as NIX_BUILDER_KEY, installed on clients via `task install-nix-build-key`).";
    };
  };
}
