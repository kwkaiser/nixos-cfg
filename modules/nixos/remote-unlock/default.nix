{ pkgs, lib, config, ... }: {

  options = {
    mine.remoteUnlock.enable =
      lib.mkEnableOption "Enables initramfs ssh for decrypting over ssh";
  };

  config = lib.mkIf config.mine.remoteUnlock.enable {
    boot.initrd.network.enable = true;
    boot.initrd.network.ssh.enable = true;
    boot.initrd.network.ssh.authorizedKeys = [ config.mine.primarySshKey ];
    boot.initrd.availableKernelModules = [ "r8169" ];
  };
}

