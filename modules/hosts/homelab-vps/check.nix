{ config, mkHostTest, ... }:
{
  config.flake.checks.x86_64-linux = {
    homelab-vps-toplevel = config.flake.nixosConfigurations.homelab-vps.config.system.build.toplevel;

    homelab-vps = mkHostTest {
      name = "homelab-vps";
      hostModule = config.flake.nixosModules.homelab-vps;

      tests = {
        ssh = true;
        k3s = true;
        nfs = true;
        builder = true;
        ci-deploy = true;
        wireguard = true;
        tailnet-dns = true;
      };

      machine = {
        virtualisation = {
          memorySize = 2048;
          cores = 2;
          diskSize = 8192;
          vlans = [ ];
          interfaces.enp1s0 = {
            vlan = 1;
            assignIP = true;
          };
        };
      };

      client.virtualisation = {
        memorySize = 512;
        cores = 1;
      };
    };
  };
}
