# nix-cfg

This repo contains [NixOS](https://nixos.org/) configurations for many of my devices. Configurations are defined in terms of [flakes](https://nixos.wiki/wiki/Flakes).

## Virtual machines

Many of the hosts have a virtual machine counterpart replacating characteristics of the hosts they're named after. This is handy mostly for testing deployments on alternative architectures, resource profiles, disk arrangements, etc.

Most of these virtual machines are defined through a very simple `virt-install` command, taking advantage of [libvirt](https://wiki.archlinux.org/title/Libvirt) and [qemu/kvm](https://wiki.archlinux.org/title/QEMU).

A suggest workfow for this is:

- `sudo <script>` to create the virtual machine quickly
- open `virt-manager` to browse & interact with virtual machines
- `sudo virsh destroy <vm>` to destroy
- `sudo virsh undefine <vm>` to undefine

## Installation

Installation of NixOS is accomplished through [NixOS anywhere](https://github.com/nix-community/nixos-anywhere) in combination with [disko](https://github.com/nix-community/disko). To bootstrap a NixOS installation, do the following:

- Create a virtual machine booting into the minimal NixOS installer via the approach defined above
- Change the root password in the installer & retrieve IP (should be network accessible via bridge device)
- Run:

```
nix --experimental-features 'nix-command flakes' \
  run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config ./hardware.nix \
  --flake .<name of flake> \
  --target-host nixos@<network addr>
```

This approach should be possible on most linux distros, provided they have nix installed.

## Development

To develop in the VM, we have a shared copy of this directory (`nixos-cfg`) directly mounted into the vm under `/mnt/nixos-cfg`. This dir is however read only, so I've been (lazily) rsync'ing it to the home directory to avoid errors caused by writing the lockfile via:

- `watch -n2 'rsync -aP --exclude="data" /mnt/nixos-cfg/ ./nixos-cfg'`

With this approach, it's relatively easy to make updates in the host, have them propagate to the VM, then rebuild.

## Rebuild

To rebuild:

- `nixos-rebuild switch --flake .#host` to rebuild locally
- `nixos-rebuild switch --flake github:kwkaiser/nixos-cfg#host` to rebuild from git
- `nix run nix-darwin -- switch --flake .#host` to rebuild on darwin

You may need to include `--no-write-lock-file` depending on the env
