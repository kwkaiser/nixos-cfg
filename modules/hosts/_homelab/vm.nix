{ lib, ... }:
let
  sharedVmConfig = {
    memorySize = 8192;
    cores = 6;
    forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
      {
        from = "host";
        host.port = 6443;
        guest.port = 6443;
      }
      {
        from = "host";
        host.port = 30443;
        guest.port = 30443;
      }
      {
        from = "host";
        host.port = 30080;
        guest.port = 30080;
      }
    ];
  };
in
{
  mine.vmTesting = sharedVmConfig // {
    diskSize = 15 * 1024; # 15GB in MB
  };

  # See modules/remote-unlock.nix: mine.remoteUnlock.ethDevice never
  # matches the VM's virtual NIC, so fully disable remote-unlock here
  # rather than let it break VM networking.
  virtualisation.vmVariant.mine.remoteUnlock.vmCompatible = lib.mkForce false;

  # Disko VM variant (used by system.build.vmWithDisko)
  virtualisation.vmVariantWithDisko = {
    disabledModules = [ ./disks.nix ];
    imports = [ ./vm-disks.nix ];
    virtualisation = sharedVmConfig;
    nix.settings.require-sigs = false;
  };
}
