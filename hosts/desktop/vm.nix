{ lib, ... }: {
  virtualisation.vmVariant = {
    mine.remoteUnlock.enable = lib.mkForce false;

    virtualisation = {
      forwardPorts = [
        {
          from = "host";
          host.port = 2222;
          guest.port = 22;
        }
      ];
    };
  };
}
