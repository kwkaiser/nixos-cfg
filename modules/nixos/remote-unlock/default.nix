{ pkgs, lib, config, ... }: {

  options = {
    mine.remoteUnlock.enable =
      lib.mkEnableOption "Enables initramfs ssh for decrypting over ssh";

    mine.remoteUnlock.requiredKernelModules = mkOption {
      type = types.listOf types.str;
      description =
        "List of kernel modules that are required for remote unlock.";
    };

    mine.remoteUnlock.ethDevice = mkOption {
      type = types.str;
      description = "The name of the ethernet device to use for remote unlock.";
    };
  };

  config = lib.mkIf config.mine.remoteUnlock.enable {

    boot.initrd = {
      network = {
        enable = true;
        ssh = {
          enable = true;
          authorizedKeys = [ config.mine.primarySshKey ];
          hostKeys = let
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

      };
      availableKernelModules = config.mine.remoteUnlock.requiredKernelModules;
    };
    networking.useDHCP = false;
    networking.interfaces.${config.mine.remoteUnlock.ethDevice}.useDHCP = true;
  };
}

