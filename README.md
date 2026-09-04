# nixos-cfg

This repo contains [NixOS](https://nixos.org/) configurations for many of my devices. Configurations are defined in terms of [flakes](https://nixos.wiki/wiki/Flakes).

## Module structure

This repo follows the [dendritic pattern](https://github.com/mightyiam/dendritic): every `.nix` file under `modules/` (besides `flake.nix` itself and non-module asset files like `.sh`/`.lua`/`.py` scripts) is a [flake-parts](https://flake.parts) module, auto-imported via [`import-tree`](https://github.com/vic/import-tree). There's no manual `imports` list to maintain.

Each feature file declares its own option under one or more of three registries:

- `nixos.modules.<name>` -> spliced into a host's NixOS system config
- `darwin.modules.<name>` -> spliced into a host's nix-darwin system config
- `homeManager.modules.<name>` -> spliced into `home-manager.users.<user>.imports`, from whichever of the above reference it

A feature that behaves identically on nixos and darwin (e.g. `git`, `tmux`) usually only needs `homeManager.modules`; a feature with real platform differences (e.g. `docker`, `ssh`) declares both `nixos.modules.<name>` and `darwin.modules.<name>` with the platform-specific halves written directly, rather than branching on an `isDarwin` flag at runtime. Files under `modules/hosts/` are the same kind of module — each one lists which named modules a given host imports and supplies genuinely host-specific data (identity overrides, disk layout, hardware, VM port-forwards). There are no `mine.<feature>.enable` flags: importing a module *is* enabling it.

`dendritic-lib.nix` at the repo root (deliberately outside `modules/`, so `import-tree` never scans it) provides `mkHmFeature`, a small helper for the common "same home-manager config on every platform" case.

## Virtual machines

VMs can be built for most machines via qemu:

- `nix --extra-experimental-features 'nix-command flakes' build .#nixosConfigurations.<host>.config.system.build.vm`
- `export QEMU_NET_OPTS="hostfwd=tcp:127.0.0.1:2222-:22,hostfwd=tcp:127.0.0.1:24680-:80"`
- `ssh -p 2222 kwkaiser@127.0.0.1`

## Installation

Installation of NixOS is accomplished through [NixOS anywhere](https://github.com/nix-community/nixos-anywhere) in combination with [disko](https://github.com/nix-community/disko). To bootstrap a NixOS installation, do the following:

- Create a virtual machine booting into the minimal NixOS installer via the approach defined above
- Change the root password in the installer & retrieve IP (should be network accessible via bridge device)
- Run:
  - `nix --experimental-features 'nix-command flakes' run github:nix-community/nixos-anywhere -- --flake .#vm --target-host nixos@<network addr>`
  - Note you may need to include `--build-on-remote` if you're building on a host that is not `x86_64` (such as macbook).

This approach should be possible on most linux distros, provided they have nix installed.

## Rebuild cheat sheet

- `nixos-rebuild switch --flake .#host` to rebuild locally
- `nixos-rebuild switch --flake .#host --target-host user@host` to rebuild remotely
- `nixos-rebuild switch --flake github:kwkaiser/nixos-cfg#host` to rebuild from git
- `nix run nix-darwin -- switch --flake .#host` to rebuild on darwin

## To update

- `nix flake update`

## To build vm:

- `nix build .#nixosConfigurations.<flake name>.config.system.build.vm`
