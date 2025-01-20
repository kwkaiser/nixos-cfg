{ inputs, lib, ... }: {
  imports = [ ./disks.nix ./boot.nix ./hardware.nix ./net.nix ./tz.nix ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";

  mine.username = "kwkaiser";
  mine.homeDir = "/home/kwkaiser";
  mine.email = "karl@kwkaiser.io";
  mine.desktop.tiling.enable = true;
  mine.shell.zsh.enable = true;
}
