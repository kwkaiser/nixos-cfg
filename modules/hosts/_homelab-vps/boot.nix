{ lib, ... }: {
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = false;
  # mkForce: qemu-vm.nix's own vmVariant default ("1024x768") otherwise
  # conflicts with this at equal priority when building the VM variant.
  boot.loader.grub.gfxmodeBios = lib.mkForce "text";
  boot.loader.grub.extraConfig = ''
    serial --unit=0 --speed=115200
    terminal_input serial
    terminal_output serial
  '';
  boot.loader.timeout = 10;

  boot.kernelParams = [ "console=ttyS0,115200n8" ];
}
