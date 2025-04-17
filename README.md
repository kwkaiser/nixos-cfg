# nixos-cfg

This repo contains [NixOS](https://nixos.org/) configurations for many of my devices. Configurations are defined in terms of [flakes](https://nixos.wiki/wiki/Flakes).

## Module structure

The modules are structured to hide replicated config & installation details from whichever host is including the module; for example relying on an `isDarwin` conditional to determine if certain packages should be installed via `brew` in a darwin installation vs. via `nix` in a `NixOS` installation. You'll find:

- `modules/common` -> modules that may be supported across multiple hosts (common packages, dev tools, etc)
- `modules/darwin` -> modules that are supported only on darwin (osx-specific apps, dock configs, etc)
- `modules/nixos` -> modules that are supported only by nixos (zfs hosts, specific desktop environments, etc)

Packages that don't require any configuration or custom installation tweaks are generally defined alongside the host.

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
