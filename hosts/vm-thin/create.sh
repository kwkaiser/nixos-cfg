#!/bin/bash

# Create VM directory if it doesn't exist
mkdir -pv data/vm-thin

# Create disk images if they don't exist
if [ ! -f "data/vm-thin/dev1.qcow2" ]; then
    qemu-img create -f qcow2 data/vm-thin/dev1.qcow2 20G
fi
if [ ! -f "data/vm-thin/dev2.qcow2" ]; then
    qemu-img create -f qcow2 data/vm-thin/dev2.qcow2 5G
fi
if [ ! -f "data/vm-thin/dev3.qcow2" ]; then
    qemu-img create -f qcow2 data/vm-thin/dev3.qcow2 5G
fi

# Create a shared directory mount point
mkdir -pv data/vm-thin/shared

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
  -drive file=data/vm-thin/dev1.qcow2,format=qcow2,if=virtio \
  -drive file=data/vm-thin/dev2.qcow2,format=qcow2,if=virtio \
  -drive file=data/vm-thin/dev3.qcow2,format=qcow2,if=virtio \
  -drive file=data/isos/nixos-minimal.iso,format=raw,if=none,id=cdrom \
  -device ide-cd,drive=cdrom \
  -boot d \
  -display cocoa \
  -vga std \
  -usb -device usb-kbd -device usb-mouse \
  -serial mon:stdio \
  -netdev vmnet-shared,id=net0 \
  -device virtio-net-pci,netdev=net0