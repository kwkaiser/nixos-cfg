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
  --target-host root@<network addr>
```

This approach should be possible on most linux distros, provided they have nix installed.

## Rebuild

To rebuild:

- `sudo nixos-rebuild switch --flake github:kwkaiser/nixos-cfg#mainarray-vm --no-write-lock-file`
