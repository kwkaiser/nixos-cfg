{
  config,
  mkNixosSystem,
  lib,
  ...
}: {
  flake.nixosConfigurations.homelab = mkNixosSystem ({lib, ...}: {
    imports = with config.nixos.modules;
      [
        identity
        base
        git
        nix-settings
        stylix
        timezone
        vm-testing

        k3s
        nfs
        ssh
        remote-unlock
      ]
      ++ [
        ./_homelab/disks.nix
        ./_homelab/hardware.nix
        ./_homelab/net.nix
        ./_homelab/boot.nix
        ./_homelab/vm.nix
      ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    system.stateVersion = "25.05";

    mine.remoteUnlock.requiredKernelModules = ["ixgbe"];
    mine.remoteUnlock.ethDevice = "enp8s0f0";
    mine.remoteUnlock.address = "192.168.2.103/24";
    mine.remoteUnlock.gateway = "192.168.2.1";
  });
}
