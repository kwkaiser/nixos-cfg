{ config, pkgs, lib, ... }: {
  virtualisation.vmVariantWithDisko = {
    # Use VM-specific disk configuration with imageSize attributes
    disabledModules = [ ./disks.nix ];
    imports = [ ./vm-disks.nix ];

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

    virtualisation.sharedDirectories = {
      nixos-cfg = {
        source = "/home/kwkaiser/Documents/nixos-cfg";
        target = "/home/kwkaiser/Documents/nixos-cfg";
      };
    };

    nix.settings.require-sigs = false;
  };

}
