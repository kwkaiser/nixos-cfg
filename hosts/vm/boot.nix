{ config, pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [ fuse ];
  boot.kernelModules = [ "9p" "9pnet" "9pnet_virtio" ];
}
