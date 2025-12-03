{ config, pkgs, ... }: {
  virtualization.vmVariantWithDisko = {
    virtualisation.forwardPorts = [{
      from = "host";
      host.port = 2222;
      guest.port = 22;
    }];
  };
}
