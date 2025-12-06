# systemd will mount an ext4 filesystem at / and zfs will mount the dataset underneath it
{ ... }: {
  disko.devices = {
    disk = {
      # Primary disk with boot & root partitions
      main = {
        type = "disk";
        device = "/dev/sdc";
        imageSize = "15G"; # 500M boot + 1G swap + 10G root + overhead
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
            swap = {
              size = "1G";
              content = { type = "swap"; };
            };
            root = {
              size = "10G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };

      data = {
        type = "disk";
        device = "/dev/sdf";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "1G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/cache";
              };
            };
          };
        };
      };

      data1 = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "1G";
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
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "1G";
              content = {
                type = "zfs";
                pool = "data";
              };
            };
          };
        };
      };

      data3 = {
        type = "disk";
        device = "/dev/sdd";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "1G";
              content = {
                type = "zfs";
                pool = "data";
              };
            };
          };
        };
      };

      data4 = {
        type = "disk";
        device = "/dev/sde";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "1G";
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
