# systemd will mount an ext4 filesystem at / and zfs will mount the dataset underneath it
{ ... }: {
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
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                settings.allowDiscards = true;
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

      data1 = {
        type = "disk";
        device = "/dev/disk/by-id/virtio-dev2";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "data";
              };
            };
          };
        };
      };
      data2 = {
        type = "disk";
        device = "/dev/disk/by-id/virtio-dev3";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "data";
              };
            };
          };
        };
      };
    };
    zpool = {
      data = {
        type = "zpool";
        mode = "mirror";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "true";
        };
        postCreateHook =
          "zfs list -t snapshot -H -o name | grep -E '^data@blank$' || zfs snapshot data@blank";

        datasets = {
          "encrypted" = {
            type = "zfs_fs";
            mountpoint = "/data";
          };
        };
      };
    };
  };
}
