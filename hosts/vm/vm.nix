{ config, pkgs, ... }: {
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048; # Use 2048MiB memory.
      cores = 3;
      diskSize = 5120; # 5GB main disk
      emptyDiskImages = [ 5120 5120 ]; # Two additional 5GB disks
    };
  };
}
