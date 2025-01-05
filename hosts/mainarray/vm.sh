#! /bin/bash

mkdir -pv data/mainarray-vm

virt-install \
  --name mainarray-vm \
  --memory 8192 \
  --vcpus 8 \
  --disk path=data/mainarray-vm/dev1.qcow2,size=2,format=qcow2 \
  --disk path=data/mainarray-vm/dev2.qcow2,size=1,format=qcow2 \
  --disk path=data/mainarray-vm/dev3.qcow2,size=1,format=qcow2 \
  --disk path=data/mainarray-vm/dev4.qcow2,size=1,format=qcow2 \
  --disk path=data/mainarray-vm/dev5.qcow2,size=1,format=qcow2 \
  --disk path=data/mainarray-vm/dev6.qcow2,size=1,format=qcow2 \
  --cdrom data/isos/nixos-minimal.iso \
  --os-variant nixos-unstable \
  --graphics spice \
  --boot uefi,cdrom,hd 