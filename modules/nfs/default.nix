{ mkModuleOption, ... }:
{
  options.nixos.modules.nfs = mkModuleOption { };

  config.nixos.modules.nfs = { config, lib, ... }: {
    options.mine.nfs.exports = lib.mkOption {
      type = lib.types.str;
      default = ''
        /bulk-pool *(rw,sync,no_subtree_check,no_root_squash)
        /cache-pool *(rw,sync,no_subtree_check,no_root_squash)
      '';
      description = "NFS exports configuration";
    };

    options.mine.nfs.openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open the NFS port on every interface. Disable on hosts whose only NFS clients are local (e.g. kubelet mounting via 127.0.0.1).";
    };

    config = {
      # Create NFS directories after filesystems are mounted
      systemd.tmpfiles.rules = [
        "d /cache-pool/nfs 0777 root root -"
        "d /bulk-pool/nfs 0777 root root -"
      ];

      services.nfs.server = {
        enable = true;
        exports = config.mine.nfs.exports;
      };

      networking.firewall = lib.mkIf config.mine.nfs.openFirewall {
        allowedTCPPorts = [ 2049 ];
        allowedUDPPorts = [ 2049 ];
      };
    };
  };
}
