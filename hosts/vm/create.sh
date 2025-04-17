#!/bin/bash

set -euo pipefail

# === CONFIGURATION ===
VM_DIR="data/vm"
ISO_PATH="data/isos/nixos-minimal.iso"
DISK1="$VM_DIR/dev1.qcow2"
DISK2="$VM_DIR/dev2.qcow2"
DISK3="$VM_DIR/dev3.qcow2"


# === PREP VM FILES ===
mkdir -pv "$VM_DIR"

[[ -f "$DISK1" ]] || qemu-img create -f qcow2 "$DISK1" 20G
[[ -f "$DISK2" ]] || qemu-img create -f qcow2 "$DISK2" 5G
[[ -f "$DISK3" ]] || qemu-img create -f qcow2 "$DISK3" 5G

# === NETWORK SETUP (LINUX ONLY) ===
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    MACHINE_ARGS=(-enable-kvm)
    DISPLAY_ARGS=(-display egl-headless -spice port=5930,disable-ticketing=on -device virtio-gpu-pci)
    QEMU_EFI_PATH="/usr/share/edk2/x64/OVMF_CODE.4m.fd"

else
    echo "Running on macOS or unsupported OS, using user-mode networking..."
    MACHINE_ARGS=(-machine q35,accel=tcg)
    DISPLAY_ARGS=(-display cocoa)
    NET_ARGS=(-netdev user,id=net0 -device virtio-net-pci,netdev=net0)
    QEMU_EFI_PATH="$(nix --experimental-features 'nix-command flakes' eval --raw nixpkgs#qemu)/share/qemu/edk2-x86_64-code.fd"
fi

# === RUN QEMU ===
qemu-system-x86_64 \
  -m 10G \
  -smp 6 \
  -cpu host \
  -drive if=pflash,format=raw,readonly=on,file="$QEMU_EFI_PATH" \
  -drive file="$DISK1",format=qcow2,if=none,id=drive1 \
  -device virtio-blk-pci,drive=drive1,serial=dev1 \
  -drive file="$DISK2",format=qcow2,if=none,id=drive2 \
  -device virtio-blk-pci,drive=drive2,serial=dev2 \
  -drive file="$DISK3",format=qcow2,if=none,id=drive3 \
  -device virtio-blk-pci,drive=drive3,serial=dev3 \
  -drive file="$ISO_PATH",format=raw,if=none,id=cdrom \
  -device ide-cd,drive=cdrom \
  -boot d \
  -usb -device usb-kbd -device usb-mouse \
  -serial mon:stdio \
  "${MACHINE_ARGS[@]}" \
  "${DISPLAY_ARGS[@]}" \
  "${NET_ARGS[@]}"


