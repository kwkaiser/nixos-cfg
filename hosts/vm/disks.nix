# systemd will mount an ext4 filesystem at / and zfs will mount the dataset underneath it
{ ... }: {

  fileSystems."/mnt/nixos-cfg" = {
    device = "shared-dir"; # The tag specified in the virt-install command
    fsType = "9p";
    options = [ "trans=virtio" "rw" "access=client" "msize=262144" ];
  };

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            primary = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
