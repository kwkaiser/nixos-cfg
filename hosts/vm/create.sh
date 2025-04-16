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

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    MACHINE_ARGS="-machine q35,accel=kvm"
    echo "Running on Linux, using KVM acceleration"
else
    MACHINE_ARGS="-machine q35,accel=tcg"
    echo "Running on macOS, using TCG emulation"
fi

# Get QEMU share directory path
QEMU_EFI_PATH="$(nix --experimental-features 'nix-command flakes' eval --raw nixpkgs#qemu)/share/qemu/edk2-x86_64-code.fd"

# Run the VM
qemu-system-x86_64 \
  -m 10G \
  -smp 6 \
  -cpu Haswell \
  $MACHINE_ARGS \
  -drive if=pflash,format=raw,readonly=on,file="$QEMU_EFI_PATH" \
  -drive file=data/vm-thin/dev1.qcow2,format=qcow2,if=none,id=drive1 \
  -device virtio-blk-pci,drive=drive1,serial=dev1 \
  -drive file=data/vm-thin/dev2.qcow2,format=qcow2,if=none,id=drive2 \
  -device virtio-blk-pci,drive=drive2,serial=dev2 \
  -drive file=data/vm-thin/dev3.qcow2,format=qcow2,if=none,id=drive3 \
  -device virtio-blk-pci,drive=drive3,serial=dev3 \
  -drive file=data/isos/nixos-minimal.iso,format=raw,if=none,id=cdrom \
  -device ide-cd,drive=cdrom \
  -boot d \
  -display cocoa \
  -vga std \
  -usb -device usb-kbd -device usb-mouse \
  -serial mon:stdio \
  -netdev vmnet-shared,id=net0 \
  -device virtio-net-pci,netdev=net0