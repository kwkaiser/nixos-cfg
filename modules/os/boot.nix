{ config, pkgs, systemd, ... }: {
  systemd.services.zfs-import-storage.enable = false;
  boot.zfs.extraPools = [ "storage" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

}
