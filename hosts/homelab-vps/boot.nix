{ ... }: {
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = false;
  boot.loader.grub.gfxmodeBios = "text";
  boot.loader.grub.extraConfig = ''
    serial --unit=0 --speed=115200
    terminal_input serial
    terminal_output serial
  '';
  boot.loader.timeout = 10;

  boot.kernelParams = [ "console=ttyS0,115200n8" ];
}
