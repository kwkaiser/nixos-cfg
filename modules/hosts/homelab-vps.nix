{ config, mkNixosSystem, lib, ... }:
{
  flake.nixosConfigurations.homelab-vps = mkNixosSystem ({ lib, ... }: {
    imports = with config.nixos.modules; [
      identity
      base
      git
      nix-settings
      stylix
      timezone
      vm-testing

      ssh
      k3s
      nfs
      borgmatic
      builder
    ]
    ++ [
      ./_homelab-vps/disks.nix
      ./_homelab-vps/hardware.nix
      ./_homelab-vps/net.nix
      ./_homelab-vps/boot.nix
      ./_homelab-vps/vm.nix
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    system.stateVersion = "25.05";

    mine.isBuilder = true;
    mine.nfs.exports = ''
      /bulk-pool 10.42.0.0/16(rw,sync,no_subtree_check,no_root_squash) 10.43.0.0/16(rw,sync,no_subtree_check,no_root_squash) 127.0.0.1(rw,sync,no_subtree_check,no_root_squash)
      /cache-pool 10.42.0.0/16(rw,sync,no_subtree_check,no_root_squash) 10.43.0.0/16(rw,sync,no_subtree_check,no_root_squash) 127.0.0.1(rw,sync,no_subtree_check,no_root_squash)
    '';

    zramSwap.enable = true;
  });
}
