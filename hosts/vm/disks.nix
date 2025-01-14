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

      y = {
        type = "disk";
        device = "/dev/vdb";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            };
          };
        };
      };
      z = {
        type = "disk";
        device = "/dev/vdc";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            };
          };
        };
      };

      zpool = {
        storage = {
          type = "zpool";
          mode = "mirror";
          mountpoint = "/storage";

          datasets = {
            dataset = {
              type = "zfs_fs";
              mountpoint = "/storage/dataset";
            };
          };
        };
        storage2 = {
          type = "zpool";
          mountpoint = "/storage2";
          rootFsOptions = { canmount = "off"; };

          datasets = {
            dataset = {
              type = "zfs_fs";
              mountpoint = "/storage2/dataset";
            };
          };
        };
      };
    };
  };
}
