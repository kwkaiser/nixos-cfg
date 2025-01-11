# systemd will mount an ext4 filesystem at / and zfs will mount the dataset underneath it
{ ... }: {
  disko.devices = {
    disk = {
      disk1 = {
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
      disk2 = {
        type = "disk";
        device = "/dev/vdb";
        content = {
          type = "zfs";
          pool = "storage";
        };
      };
      disk3 = {
        type = "disk";
        device = "/dev/vdc";
        content = {
          type = "zfs";
          pool = "storage";
        };
      };
    };
    zpool = {
      storage = {
        type = "zpool";
        mode = "mirror";
        mountpoint = "/mnt/ironwolf";
        datasets = {
          media = {
            type = "zfs_fs";
            #options.mountpoint = "legacy";
            options.mountpoint = "/mnt/ironwolf/media";
          };
          appdata = {
            type = "zfs_fs";
            #options.mountpoint = "legacy";
            options.mountpoint = "/mnt/ironwolf/appdata";
          };
        };
      };
    };
  };
}
