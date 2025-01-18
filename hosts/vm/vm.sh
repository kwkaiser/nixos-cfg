#! /bin/bash

mkdir -pv data/vm

  # --memorybacking access.mode=shared \

virt-install \
  --name vm \
  --memory 8192 \
  --vcpus 8 \
  --filesystem source=/home/kwkaiser/desktop/nix,target=shared-dir,type=mount,mode=passthrough \
  --network network=default \
  --disk path=data/vm/dev1.qcow2,size=20,format=qcow2 \
  --disk path=data/vm/dev2.qcow2,size=5,format=qcow2 \
  --disk path=data/vm/dev3.qcow2,size=5,format=qcow2 \
  --cdrom data/isos/nixos-minimal.iso \
  --os-variant nixos-unstable \
  --video virtio \
  --graphics spice \
  --boot uefi,cdrom,hd 