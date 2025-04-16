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

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    MACHINE_ARGS="-enable-kvm"
    DISPLAY_ARGS="-display gtk"
    NET_ARGS="-netdev vmnet-shared,id=net0" 
    QEMU_EFI_PATH="/usr/share/edk2/x64/OVMF_CODE.4m.fd"

    echo "Running on Linux, using KVM acceleration with GTK display"
else
    MACHINE_ARGS="-machine q35,accel=tcg"
    DISPLAY_ARGS="-display cocoa"
    NET_ARGS="-netdev user,id=net0 -device virtio-net-pci,netdev=net0" 
    QEMU_EFI_PATH="$(nix --experimental-features 'nix-command flakes' eval --raw nixpkgs#qemu)/share/qemu/edk2-x86_64-code.fd"
    echo "Running on macOS, using TCG emulation"
fi

# Get QEMU share directory path

# Run the VM
qemu-system-x86_64 \
  -m 10G \
  -smp 6 \
  -cpu host \
  "$MACHINE_ARGS" \
  "$DISPLAY_ARGS" \
  "$NET_ARGS" \
  -drive if=pflash,format=raw,readonly=on,file="$QEMU_EFI_PATH" \
  -drive file=data/vm/dev1.qcow2,format=qcow2,if=none,id=drive1 \
  -device virtio-blk-pci,drive=drive1,serial=dev1 \
  -drive file=data/vm/dev2.qcow2,format=qcow2,if=none,id=drive2 \
  -device virtio-blk-pci,drive=drive2,serial=dev2 \
  -drive file=data/vm/dev3.qcow2,format=qcow2,if=none,id=drive3 \
  -device virtio-blk-pci,drive=drive3,serial=dev3 \
  -drive file=data/isos/nixos-minimal.iso,format=raw,if=none,id=cdrom \
  -device ide-cd,drive=cdrom \
  -boot d \
  -usb -device usb-kbd -device usb-mouse \
  -serial mon:stdio \
  -device virtio-net-pci,netdev=net0