---
description: Build and run a NixOS VM for a given host to interactively test config changes
argument-hint: <hostname>
---

Build and run a NixOS VM for `$ARGUMENTS` (e.g. `desktop`), then help the user verify behavior over SSH.

## How this repo's VM testing works

This repo follows the [dendritic pattern](https://github.com/mightyiam/dendritic): every `modules/*.nix` file is a flake-parts module contributing to `nixos.modules.<name>` / `darwin.modules.<name>` / `homeManager.modules.<name>` registries, and each host under `modules/hosts/<hostname>.nix` lists which of those it imports.

### VM config pattern

Each host that supports VM testing imports the shared `vm-testing` module (`modules/vm-testing.nix`, registry key `nixos.modules.vm-testing`) plus a thin per-host `modules/hosts/_<hostname>/vm.nix` (not itself auto-imported — it's referenced by relative path from `modules/hosts/<hostname>.nix`, matching the underscore-prefixed-directory convention `import-tree` skips) that sets `mine.vmTesting.{memorySize,cores,diskSize,forwardPorts}`. See `modules/hosts/_homelab/vm.nix` and `modules/hosts/_desktop/vm.nix` for examples.

Minimum per-host `vm.nix` for a desktop-style host:

```nix
{ lib, ... }: {
  mine.vmTesting = {
    memorySize = 4096;
    cores = 4;
    forwardPorts = [
      { from = "host"; host.port = 2222; guest.port = 22; }
    ];
  };
}
```

### Known incompatibilities in vmVariant

- **`mine.remoteUnlock`**: generates initrd SSH host keys via `pkgs.runCommand` (derivation paths) and binds to a physical ethernet device name that never matches the VM's virtual NIC. Hosts that import `remote-unlock` (`modules/remote-unlock.nix`) must also force `virtualisation.vmVariant.mine.remoteUnlock.vmCompatible = lib.mkForce false;` in their per-host `vm.nix` — see `modules/hosts/_desktop/vm.nix`.
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

This opens a QEMU window. The default user is `kwkaiser`, password `bingus` (set via `initialPassword` in `modules/identity.nix`).

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

