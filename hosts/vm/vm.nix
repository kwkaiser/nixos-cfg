{ config, pkgs, ... }: {
  virtualisation.qemu.options = [
    "-netdev"
    "user,id=net0,hostfwd=tcp::2222-:22"
    "-device"
    "virtio-net-pci,netdev=net0"
  ];

}
