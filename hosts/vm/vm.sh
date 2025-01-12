#! /bin/bash

mkdir -pv data/vm

virt-install \
  --name vm \
  --memory 8192 \
  --vcpus 8 \
  --filesystem source=/home/kwkaiser/desktop/nix,target=/nixos-cfg \
  --network network=default \
  --disk path=data/vm/dev1.qcow2,size=20,format=qcow2 \
  --cdrom data/isos/nixos-minimal.iso \
  --os-variant nixos-unstable \
  --graphics spice \
  --boot uefi,cdrom,hd 