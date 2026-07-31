{...}: {
  # bulk-pool and cache-pool already exist on separate physical disks and hold
  # live data; they are intentionally not declared here so disko never
  # touches them. They're imported post-install via boot.zfs.extraPools.
  boot.zfs.extraPools = ["bulk-pool" "cache-pool"];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_1TB_S59VNJ0N105754E";
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
                mountOptions = ["umask=0077"];
              };
            };
            swap = {
              size = "976M";
              content = {type = "swap";};
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
    };
  };
}
