{ config, pkgs, ... }: {
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048;
      cores = 3;
      diskSize = 5120;

      qemu.drives = [
        {
          name = "dev1";
          file = builtins.getEnv "PWD" + "/data/vm-thin/drive1.qcow2";
          deviceExtraOpts = {
            id = "dev1";
            serial = "dev1";
          };
        }
        {
          name = "dev2";
          file = builtins.getEnv "PWD" + "/data/vm-thin/drive2.qcow2";
          deviceExtraOpts = {
            id = "dev2";
            serial = "dev2";
          };
        }
        {
          name = "dev3";
          file = builtins.getEnv "PWD" + "/data/vm-thin/drive3.qcow2";
          deviceExtraOpts = {
            id = "dev3";
            serial = "dev3";
          };
        }
      ];
    };
  };
}
