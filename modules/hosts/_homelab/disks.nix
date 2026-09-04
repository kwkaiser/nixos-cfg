{...}: {
  # bulk-pool/cache-pool are created fresh by disko below (destroying whatever
  # is currently on those disks). Encryption lives entirely at the LUKS layer
  # on each member disk (same pattern as desktop's multi-disk setup) - ZFS
  # itself runs unencrypted on top of the decrypted /dev/mapper/* devices, so
  # there's no separate ZFS key/passphrase to manage.
  #
  # All LUKS devices default to initrdUnlock = true, so root and every data
  # disk are unlocked together in one ssh homelab-unlock session (same
  # passphrase, typed once per prompt) - see the migration runbook. The data
  # disks (not root) additionally set crypttabExtraOpts = ["nofail"], so a
  # missing/failing disk degrades the pool instead of blocking boot entirely.
  #
  # Data disks are referenced by /dev/disk/by-path (physical HBA/SATA port,
  # stable across a disk swap in the same bay) rather than by-id (tied to
  # that exact disk's serial number), so replacing a failed disk doesn't
  # require a config change - just cryptsetup luksFormat + zpool replace
  # against whatever's physically in that slot. The OS disk stays pinned by
  # -id since it isn't expected to be hot-swapped.
  boot.zfs.forceImportRoot = false;

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
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "root";
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

      # bulk-pool: raidz2 across 4 disks on the onboard SAS HBA.
      bulk-disk1 = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:04:00.0-sas-phy0-lun-0";
        content = {
          type = "gpt";
          partitions.luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "bulk-disk1";
              settings = {
                allowDiscards = true;
                crypttabExtraOpts = ["nofail"];
              };
              content = {
                type = "zfs";
                pool = "bulk-pool";
              };
            };
          };
        };
      };
      bulk-disk2 = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:04:00.0-sas-phy1-lun-0";
        content = {
          type = "gpt";
          partitions.luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "bulk-disk2";
              settings = {
                allowDiscards = true;
                crypttabExtraOpts = ["nofail"];
              };
              content = {
                type = "zfs";
                pool = "bulk-pool";
              };
            };
          };
        };
      };
      bulk-disk3 = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:04:00.0-sas-phy2-lun-0";
        content = {
          type = "gpt";
          partitions.luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "bulk-disk3";
              settings = {
                allowDiscards = true;
                crypttabExtraOpts = ["nofail"];
              };
              content = {
                type = "zfs";
                pool = "bulk-pool";
              };
            };
          };
        };
      };
      bulk-disk4 = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:04:00.0-sas-phy3-lun-0";
        content = {
          type = "gpt";
          partitions.luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "bulk-disk4";
              settings = {
                allowDiscards = true;
                crypttabExtraOpts = ["nofail"];
              };
              content = {
                type = "zfs";
                pool = "bulk-pool";
              };
            };
          };
        };
      };

      # cache-pool: single SSD on its own SATA port.
      cache-disk1 = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:07:00.0-ata-1";
        content = {
          type = "gpt";
          partitions.luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cache-disk1";
              settings = {
                allowDiscards = true;
                crypttabExtraOpts = ["nofail"];
              };
              content = {
                type = "zfs";
                pool = "cache-pool";
              };
            };
          };
        };
      };
    };

    zpool = {
      bulk-pool = {
        type = "zpool";
        mode = "raidz2";
        options.ashift = "12";
        rootFsOptions.compression = "lz4";
        mountpoint = "/bulk-pool";
        datasets.nfs = {
          type = "zfs_fs";
          mountpoint = "/bulk-pool/nfs";
        };
      };

      cache-pool = {
        type = "zpool";
        mode = "";
        options.ashift = "12";
        rootFsOptions.compression = "lz4";
        mountpoint = "/cache-pool";
        datasets.nfs = {
          type = "zfs_fs";
          mountpoint = "/cache-pool/nfs";
        };
      };
    };
  };
}
