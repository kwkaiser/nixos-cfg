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
        module-hardening = true;
        fail2ban = true;
      };

      machine = {
        virtualisation = {
          memorySize = 1536;
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
        memorySize = 384;
        cores = 1;
      };
    };
  };
}
