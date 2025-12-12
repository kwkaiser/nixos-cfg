{ pkgs, lib, config, ... }: {

  options = {
    mine.nfs.enable = lib.mkEnableOption "Enables NFS server";

    mine.nfs.exports = lib.mkOption {
      type = lib.types.str;
      default = ''
        /bulk-pool *(rw,sync,no_subtree_check,no_root_squash)
        /cache-pool *(rw,sync,no_subtree_check,no_root_squash)
      '';
      description = "NFS exports configuration";
    };
  };

  config = lib.mkIf config.mine.nfs.enable {

    # Create NFS directories after filesystems are mounted
    systemd.tmpfiles.rules = [
      "d /cache-pool/nfs 0755 root root -"
      "d /bulk-pool/nfs 0755 root root -"
    ];

    services.nfs.server = {
      enable = true;
      exports = config.mine.nfs.exports;
    };

    networking.firewall = {
      allowedTCPPorts = [ 2049 ];
      allowedUDPPorts = [ 2049 ];
    };
  };
}

