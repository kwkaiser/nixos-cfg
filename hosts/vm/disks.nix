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

      data1 = {
        type = "disk";
        device = "/dev/disk/by-id/virtio-dev2_serial";
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
        device = "/dev/disk/by-id/virtio-dev3_serial";
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
            # options = {
            #   encryption = "aes-256-gcm";
            #   keyformat = "passphrase";
            #   keylocation = "file:///tmp/secret.key";
            # };
            # # use this to read the key during boot
            # postCreateHook = ''
            #   zfs set keylocation="prompt" "data/encrypted";
            # '';
          };
        };
      };
    };
  };
}
