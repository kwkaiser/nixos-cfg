{ mkModuleOption, ... }:
{
  options.nixos.modules.remote-unlock = mkModuleOption { };

  config.nixos.modules.remote-unlock = { pkgs, lib, config, ... }: {
    options.mine.remoteUnlock = {
      requiredKernelModules = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "List of kernel modules that are required for remote unlock.";
      };

      ethDevice = lib.mkOption {
        type = lib.types.str;
        description = "The name of the ethernet device to use for remote unlock.";
      };

      address = lib.mkOption {
        type = lib.types.str;
        default = "192.168.4.110/24";
        description = "Static address (CIDR) to assign to ethDevice in the initrd.";
      };

      gateway = lib.mkOption {
        type = lib.types.str;
        default = "192.168.4.1";
        description = "Gateway to route through in the initrd.";
      };

      # Internal escape hatch (not a feature-enable gate): the vm-testing
      # module forces this to false in virtualisation.vmVariant, since the
      # ethDevice named here never matches the VM's virtual NIC and static
      # DHCP=no networking would otherwise break VM networking entirely.
      vmCompatible = lib.mkOption {
        type = lib.types.bool;
        default = true;
        internal = true;
      };
    };

    config = lib.mkIf config.mine.remoteUnlock.vmCompatible {
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
  };
}
