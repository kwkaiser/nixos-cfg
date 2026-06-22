---
description: Build and run a NixOS VM for a given host to interactively test config changes
argument-hint: <hostname>
---

Build and run a NixOS VM for `$ARGUMENTS` (e.g. `desktop`), then help the user verify behavior over SSH.

## How this repo's VM testing works

### VM config pattern

Each host that supports VM testing has a `hosts/<hostname>/vm.nix` imported in its `default.nix`. This file uses the `virtualisation.vmVariant` module to apply VM-only overrides without affecting the real system build. See `hosts/homelab/vm.nix` and `hosts/desktop/vm.nix` for examples.

Minimum `vm.nix` for a desktop-style host:

```nix
{ lib, ... }: {
  virtualisation.vmVariant = {
    # Disable modules that are incompatible with the VM bootloader
    mine.remoteUnlock.enable = lib.mkForce false;

    virtualisation = {
      forwardPorts = [
        { from = "host"; host.port = 2222; guest.port = 22; }
      ];
    };
  };
}
```

### Known incompatibilities in vmVariant

- **`mine.remoteUnlock`**: generates initrd SSH host keys via `pkgs.runCommand` (derivation paths). The VM variant's bootloader requires unquoted Nix store paths for `boot.initrd.secrets`, so this module must be force-disabled in `vmVariant`.
- Any module that sets `boot.initrd.secrets` to derivation values will hit the same assertion failure.

### Build

```bash
nix build .#nixosConfigurations.<hostname>.config.system.build.vm
```

New files must be `git add`ed before Nix can see them — Nix reads the flake from the git tree, so untracked files cause evaluation errors.

### Run

```bash
./result/bin/run-<hostname>-vm
```

This opens a QEMU window. The default user is `kwkaiser`, password `bingus` (set via `initialPassword` in `modules/user.nix`).

### SSH in

SSH is forwarded from host port 2222 to guest port 22:

```bash
ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null kwkaiser@localhost
```

### Kill the VM

```bash
pkill -f "qemu.*<hostname>"
```

## Running a test

1. If no `vm.nix` exists for the host, create one following the pattern above and `git add` it.
2. Build: `nix build .#nixosConfigurations.$ARGUMENTS.config.system.build.vm`
3. Run in background: `./result/bin/run-$ARGUMENTS-vm &`
4. Tell the user to interact with the VM window (e.g. log in via tuigreet).
5. SSH in to verify the behavior once the user confirms they've completed the UI step.
6. Kill with `pkill -f "qemu.*$ARGUMENTS"` when done.
