# systemd will mount an ext4 filesystem at / and zfs will mount the dataset underneath it
{ ... }: {
  disko.devices = {
    disk = {

      # Primary disk with boot & root partitions
      main = {
        type = "disk";
        device = "/dev/sdc";
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

      data = {
        type = "disk";
        device = "/dev/sdf";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/cache";
              };
            };
          };
        };
      };

    };
  };
}
