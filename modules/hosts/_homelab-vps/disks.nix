{ ... }: {
  # /nix lives on its own LVM volume group backed by a Hetzner Volume rather
  # than the local disk, so storage scales independently of the server plan
  # (Volumes bill per-GB and grow on their own; the local disk size is fixed
  # per plan tier). Growing later is pvcreate + vgextend + lvextend +
  # resize2fs against a newly attached volume - no reinstall.
  #
  # nix-store's device path is the Hetzner Volume's stable by-id path
  # (/dev/disk/by-id/scsi-0HC_Volume_<id>), not /dev/sdb - Hetzner doesn't
  # guarantee attachment order once more than one volume is attached. Fill
  # in the real id from the hcloud_volume terraform output.
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
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

      nix-store = {
        type = "disk";
        device = "/dev/disk/by-id/scsi-0HC_Volume_<id>";
        content = {
          type = "gpt";
          partitions.primary = {
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "vgnix";
            };
          };
        };
      };
    };

    lvm_vg = {
      vgnix = {
        type = "lvm_vg";
        lvs.nix = {
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/nix";
          };
        };
      };
    };
  };
}
