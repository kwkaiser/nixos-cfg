#!/bin/bash

# Create VM directory if it doesn't exist
mkdir -pv data/vm

# Create disk images if they don't exist
if [ ! -f "data/vm/dev1.qcow2" ]; then
    qemu-img create -f qcow2 data/vm/dev1.qcow2 20G
fi
if [ ! -f "data/vm/dev2.qcow2" ]; then
    qemu-img create -f qcow2 data/vm/dev2.qcow2 5G
fi
if [ ! -f "data/vm/dev3.qcow2" ]; then
    qemu-img create -f qcow2 data/vm/dev3.qcow2 5G
fi

# Create a shared directory mount point
mkdir -pv data/vm/shared

# Mount the host directory
# mount --bind /home/kwkaiser/desktop/nix data/vm/shared

# Run the VM
qemu-system-x86_64 \
  -m 4G \
  -smp 2 \
  -cpu Haswell \
  -machine q35,accel=tcg \
  -drive file=data/vm/dev1.qcow2,format=qcow2,if=virtio \
  -drive file=data/vm/dev2.qcow2,format=qcow2,if=virtio \
  -drive file=data/vm/dev3.qcow2,format=qcow2,if=virtio \
  -drive file=data/isos/nixos-minimal.iso,format=raw,if=none,id=cdrom \
  -device ide-cd,drive=cdrom \
  -boot d \
  -display cocoa \
  -vga std \
  -usb -device usb-kbd -device usb-mouse \
  -serial mon:stdio \
  -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:80,hostfwd=tcp::8443-:443 \
  -device virtio-net-pci,netdev=net0

# Cleanup: unmount the shared directory when done
# umount data/vm/shared 