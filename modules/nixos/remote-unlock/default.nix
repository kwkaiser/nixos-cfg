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

    # generate ephemeral host keys declaratively
    boot.initrd.network.ssh.hostKeys = let
      hostKeyED = pkgs.runCommand "initrd-ssh-host-ed25519" {
        buildInputs = [ pkgs.openssh ];
      } ''
        ssh-keygen -t ed25519 -N "" -f $out
      '';
      hostKeyRSA = pkgs.runCommand "initrd-ssh-host-rsa" {
        buildInputs = [ pkgs.openssh ];
      } ''
        ssh-keygen -t rsa -N "" -f $out
      '';

    in [ hostKeyRSA hostKeyED ];
  };
}

