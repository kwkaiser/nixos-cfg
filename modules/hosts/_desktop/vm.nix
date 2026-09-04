{ lib, ... }: {
  mine.vmTesting = {
    memorySize = 4096;
    cores = 4;
    forwardPorts = [
      {
        from = "host";
        host.port = 2223;
        guest.port = 22;
      }
    ];
  };

  virtualisation.vmVariant = {
    virtualisation = {
      # No attached display, so this reproduces the "no physical monitor"
      # scenario (greetd/tuigreet/Hyprland headless bootstrap) for a fast
      # local debug loop instead of testing against the real desktop.
      graphics = true;
    };
    # See modules/remote-unlock.nix: mine.remoteUnlock.ethDevice never
    # matches the VM's virtual NIC, so fully disable remote-unlock here
    # rather than let it break VM networking.
    mine.remoteUnlock.vmCompatible = lib.mkForce false;
  };
}
