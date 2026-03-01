{nixpkgs, ...}: {
  virtualisation = {
    # Regular VM variant (used by system.build.vm)
    vmVariant = {
      virtualisation = {
        host.pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        diskSize = 15 * 1024; # 15GB in MB
        forwardPorts = [
          {
            from = "host";
            host.port = 2222;
            guest.port = 22;
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
        memorySize = 8192;
        cores = 6;
      };
    };

    # Disko VM variant (used by system.build.vmWithDisko)
    vmVariantWithDisko = {
      # Use VM-specific disk configuration with imageSize attributes
      disabledModules = [./disks.nix];
      imports = [./vm-disks.nix];

      # Port forwarding for convenience
      virtualisation = {
        # Use Darwin host packages for QEMU when running VM from macOS
        host.pkgs = nixpkgs.legacyPackages.aarch64-darwin;
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
            host.port = 80;
            guest.port = 30080;
          }
          {
            from = "host";
            host.port = 443;
            guest.port = 30443;
          }
        ];
        memorySize = 8192;
        cores = 6;
        #sharedDirectories = {
        #  nixos-cfg = {
        #    source = "/home/kwkaiser/Documents/nixos-cfg";
        #    target = "/home/kwkaiser/Documents/nixos-cfg";
        #  };
        #};
      };

      nix.settings.require-sigs = false;
    };
  };
}
