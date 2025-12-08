{ config, pkgs, lib, ... }: {
  virtualisation.vmVariantWithDisko = {
    # Use VM-specific disk configuration with imageSize attributes
    disabledModules = [ ./disks.nix ];
    imports = [ ./vm-disks.nix ];

    # Port forwarding for convenience
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
      {
        from = "host";
        host.port = 30080;
        guest.port = 30080;
      }
      {
        from = "host";
        host.port = 30443;
        guest.port = 30443;
      }
    ];

    virtualisation.memorySize = 8192;
    virtualisation.cores = 6;
    virtualisation.sharedDirectories = {
      nixos-cfg = {
        source = "/home/kwkaiser/Documents/nixos-cfg";
        target = "/home/kwkaiser/Documents/nixos-cfg";
      };

      # Allow for injection of pre-loaded container images to reduce 429 responses from docker hub when testing
      k3s-images = {
        source = "/home/kwkaiser/Documents/nixos-cfg/data/containers";
        target = "/var/lib/rancher/k3s/agent/images";
      };
    };

    nix.settings.require-sigs = false;
  };

}
