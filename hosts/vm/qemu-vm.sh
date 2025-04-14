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
qemu-system-aarch64 \
    -machine virt,highmem=on \
    -accel hvf \
    -cpu host \
    -smp 8 \
    -m 8G \
    -device virtio-gpu-pci \
    -display default,show-cursor=on \
    -device qemu-xhci \
    -device usb-kbd \
    -device usb-tablet \
    -device virtio-net,netdev=net0 \
    -netdev user,id=net0 \
    -drive file=data/vm/dev1.qcow2,format=qcow2,if=virtio \
    -drive file=data/vm/dev2.qcow2,format=qcow2,if=virtio \
    -drive file=data/vm/dev3.qcow2,format=qcow2,if=virtio \
    -cdrom data/isos/nixos-minimal.iso \
    -fsdev local,id=shared,path=data/vm/shared,security_model=passthrough \
    -device virtio-9p-pci,fsdev=shared,mount_tag=shared-dir

# Cleanup: unmount the shared directory when done
# umount data/vm/shared 