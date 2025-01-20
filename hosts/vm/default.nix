{ inputs, lib, ... }: {
  imports = [ ./disks.nix ./boot.nix ./hardware.nix ./net.nix ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = 5;

  mine.username = "kwkaiser";
  mine.homeDir = "/Users/kwkaiser";
  mine.email = "karl@kwkaiser.io";
  mine.desktop.tiling.enable = true;
}
