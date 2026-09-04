{ ... }: let
  sharedVmConfig = {
    memorySize = 2048;
    cores = 2;
    forwardPorts = [
      {
        from = "host";
        host.port = 2223;
        guest.port = 22;
      }
      {
        from = "host";
        host.port = 8080;
        guest.port = 80;
      }
      {
        from = "host";
        host.port = 8443;
        guest.port = 443;
      }
    ];
  };
in {
  mine.vmTesting = sharedVmConfig // {
    diskSize = 10 * 1024;
  };

  virtualisation.vmVariantWithDisko = {
    disabledModules = [ ./disks.nix ];
    imports = [ ./vm-disks.nix ];
    virtualisation = sharedVmConfig;
    nix.settings.require-sigs = false;
  };
}
