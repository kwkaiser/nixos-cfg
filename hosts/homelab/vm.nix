{ config, pkgs, ... }: {
  virtualisation.vmVariantWithDisko = {
    virtualisation.forwardPorts = [
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
    ];
  };
}
