{nixpkgs, ...}: let
  sharedVmConfig = {
    host.pkgs = nixpkgs.legacyPackages.aarch64-darwin;
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
in {
  virtualisation = {
    # Regular vm variant; invoked when running on macOS since disko is not well supported
    vmVariant = {
      virtualisation =
        sharedVmConfig
        // {
          diskSize = 15 * 1024; # 15GB in MB
        };
    };

    # Disko VM variant (used by system.build.vmWithDisko)
    vmVariantWithDisko = {
      disabledModules = [./disks.nix];
      imports = [./vm-disks.nix];
      virtualisation = sharedVmConfig;
      nix.settings.require-sigs = false;
    };
  };
}
