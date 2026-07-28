{ lib, ... }: {
  virtualisation.vmVariant = {
    mine.remoteUnlock.enable = lib.mkForce false;

    virtualisation = {
      # No attached display, so this reproduces the "no physical monitor"
      # scenario (greetd/tuigreet/Hyprland headless bootstrap) for a fast
      # local debug loop instead of testing against the real desktop.
      graphics = false;
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
  };
}
