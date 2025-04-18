{ config, pkgs, ... }: {
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048;
      cores = 3;

      qemu.drives = [{
        name = "foo";
        file = builtins.getEnv "PWD" + "/test.qcow2";
        deviceExtraOpts = {
          id = "my_drive";
          serial = "1234567890";
        };
      }];
    };
  };
}
