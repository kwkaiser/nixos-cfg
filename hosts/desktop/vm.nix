{ lib, inputs, ... }: {
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

  # Boots off a disko-formatted virtual disk instead of the default vm
  # image, so the guest actually runs on the real btrfs subvolume layout
  # (minus LUKS, which disko's vm tooling can't drive non-interactively).
  # Build/run via `.config.system.build.vmWithDisko`.
  virtualisation.vmVariantWithDisko = {
    disabledModules = [ ./disks.nix ];
    imports = [ ./vm-disks.nix ];

    mine.remoteUnlock.enable = lib.mkForce false;
    nix.settings.require-sigs = false;

    # disko's imageBuilder passes an aggregateModules derivation as vmTools'
    # `kernel` arg to format the virtual disk; current nixpkgs-unstable's
    # vmTools now requires that arg to carry a `.target` attribute, which
    # breaks this. nixos-25.11 predates that vmTools change.
    disko.imageBuilder.pkgs = inputs.nixpkgs-darwin-stable.legacyPackages.x86_64-linux;

    virtualisation = {
      graphics = false;
      memorySize = 8192;
      cores = 8;

      # Default qemu-vm behavior overlays /nix/store on a RAM-backed tmpfs
      # capped at half of memorySize, ignoring the real btrfs disk entirely.
      # We need writes (devbox packages, pnpm store, etc.) to actually land
      # on btrfs for this experiment, so route them to the disko-mounted disk.
      writableStoreUseTmpfs = false;

      forwardPorts = [
        {
          from = "host";
          host.port = 2224;
          guest.port = 22;
        }
      ];
    };
  };
}
