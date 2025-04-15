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

# Detect OS and set machine/acceleration parameters
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux with KVM
    MACHINE_ARGS="-machine q35,accel=kvm"
    echo "Running on Linux, using KVM acceleration"
else
    # macOS with TCG
    MACHINE_ARGS="-machine q35,accel=tcg"
    echo "Running on macOS, using TCG emulation"
fi

# Run the VM
qemu-system-x86_64 \
  -m 4G \
  -smp 2 \
  -cpu Haswell \
  $MACHINE_ARGS \
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
  -netdev vmnet-shared,id=net0 \
  -device virtio-net-pci,netdev=net0

# Cleanup: unmount the shared directory when done
# umount data/vm/shared 