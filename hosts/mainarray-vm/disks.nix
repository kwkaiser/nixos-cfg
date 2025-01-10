{ ... }: {

  fileSystems."/zstorage".options = [ "noauto" ];
  disko.devices = {
    disk = {
      nixos = {
        device = "/dev/vda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
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
                pool = "zstorage";
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
                pool = "zstorage";
              };
            };
          };
        };
      };
    };

    zpool = {
      zstorage = {
        type = "zpool";
        mode = "mirror";
        rootFsOptions = { compression = "zstd"; };

        mountpoint = "/zstorage";

        datasets = {
          data = {
            type = "zfs_fs";
            options.mountpoint = "/storage/data";
          };
        };
      };
    };

  };
}
