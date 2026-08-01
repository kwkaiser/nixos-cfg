{ pkgs, lib, config, ... }: {

  options = {
    mine.remoteUnlock.enable =
      lib.mkEnableOption "Enables initramfs ssh for decrypting over ssh";

    mine.remoteUnlock.requiredKernelModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description =
        "List of kernel modules that are required for remote unlock.";
    };

    mine.remoteUnlock.ethDevice = lib.mkOption {
      type = lib.types.str;
      description = "The name of the ethernet device to use for remote unlock.";
    };

    mine.remoteUnlock.address = lib.mkOption {
      type = lib.types.str;
      default = "192.168.4.110/24";
      description = "Static address (CIDR) to assign to ethDevice in the initrd.";
    };

    mine.remoteUnlock.gateway = lib.mkOption {
      type = lib.types.str;
      default = "192.168.4.1";
      description = "Gateway to route through in the initrd.";
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
      systemd.network.networks."40-${config.mine.remoteUnlock.ethDevice}" = {
        DHCP = lib.mkOverride 10 "no";
        address = [ config.mine.remoteUnlock.address ];
        routes = [ { Gateway = config.mine.remoteUnlock.gateway; } ];
      };
    };
    networking.useDHCP = false;
    networking.interfaces.${config.mine.remoteUnlock.ethDevice}.useDHCP = true;
  };
}

