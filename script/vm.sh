#!/bin/bash

parse_args() {
    if [ $# -lt 3 ]; then
        echo "Error: Hostname, architecture, and number of disks arguments are required"
        echo "Usage: $0 <hostname> <architecture> <num_disks>"
        echo "Example: $0 myvm linux 3"
        exit 1
    fi
    
    HOST="$1"
    ARCH="$2"
    NUM_DISKS="$3"
}

create_disks () {
    local num_disks=$1
    mkdir -p "data/$HOST"
    
    for i in $(seq 1 "$num_disks"); do
        if [ ! -f "data/$HOST/disk${i}.qcow2" ]; then
            # First disk is 20G, others are 5G
            local size="5G"
            if [ "$i" -eq 1 ]; then
                size="20G"
            fi
            qemu-img create -f qcow2 "data/$HOST/disk${i}.qcow2" $size
        fi
    done
}

set_qemu_args () {
    local num_disks=$1
    if [[ "$ARCH" == "linux"* ]]; then
        MACHINE_ARGS=(-enable-kvm)
        DISPLAY_ARGS=(-display gtk)
        NET_ARGS=(-netdev vmnet-shared,id=net0)
        QEMU_EFI_PATH="/usr/share/edk2/x64/OVMF_CODE.4m.fd"

        echo "Running on Linux, using KVM acceleration with GTK display"
    else
        MACHINE_ARGS=(-machine q35,accel=tcg)
        DISPLAY_ARGS=(-display cocoa)
        NET_ARGS=(-netdev user,id=net0 -device virtio-net-pci,netdev=net0)
        QEMU_EFI_PATH="$(nix --experimental-features 'nix-command flakes' eval --raw nixpkgs#qemu)/share/qemu/edk2-x86_64-code.fd"
        echo "Running on macOS, using TCG emulation"
    fi

    # Build disk arguments dynamically
    DISK_ARGS=()
    for i in $(seq 1 "$num_disks"); do
        DISK_ARGS+=(
            -drive "file=data/$HOST/disk${i}.qcow2,format=qcow2,if=none,id=drive${i}"
            -device "virtio-blk-pci,drive=drive${i},serial=dev${i}"
        )
    done
}

run_vm() {
    # Run the VM
    qemu-system-x86_64 \
    -m 10G \
    -smp 6 \
    -cpu host \
    "${MACHINE_ARGS[@]}" \
    "${DISPLAY_ARGS[@]}" \
    "${NET_ARGS[@]}" \
    -drive if=pflash,format=raw,readonly=on,file="$QEMU_EFI_PATH" \
    "${DISK_ARGS[@]}" \
    -drive file=data/isos/nixos-minimal.iso,format=raw,if=none,id=cdrom \
    -device ide-cd,drive=cdrom \
    -boot d \
    -usb -device usb-kbd -device usb-mouse \
    -serial mon:stdio \
    -device virtio-net-pci,netdev=net0
}

# Parse command line arguments
parse_args "$@"
create_disks "$NUM_DISKS"
set_qemu_args "$NUM_DISKS"
run_vm
