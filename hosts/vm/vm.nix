{ config, pkgs, ... }: {
  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 2048; # Use 2048MiB memory.
      cores = 3;
      qemu.options = [
        "-netdev"
        "user,id=net0,hostfwd=tcp::2222-:22"
        "-device"
        "virtio-net-pci,netdev=net0"
        "-spice"
        "port=5900,addr=127.0.0.1,disable-ticketing"
        "-device"
        "virtio-serial-pci"
        "-chardev"
        "spicevmc,id=vdagent,name=vdagent"
        "-device"
        "virtserialport,chardev=vdagent,name=com.redhat.spice.0"
      ];
    };
  };
}
