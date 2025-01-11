#! /bin/bash

mkdir -pv data/mainarray-vm

virt-install \
  --name mainarray-vm \
  --memory 8192 \
  --vcpus 8 \
  --network network=default \
  --disk path=data/mainarray-vm/dev1.qcow2,size=20,format=qcow2 \
  --cdrom data/isos/nixos-minimal.iso \
  --os-variant nixos-unstable \
  --graphics spice \
  --boot uefi,cdrom,hd 