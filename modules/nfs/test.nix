{
  config.nixos.modules.nfs =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.mine.vmTest.tests.nfs or false) {
        mine.vmTest.scripts.nfs = ''
          machine.wait_for_unit("nfs-server.service")
          machine.succeed(
              "mkdir -p /mnt/bulk",
              "mount -t nfs -o nfsvers=4 127.0.0.1:/bulk-pool /mnt/bulk",
              "touch /mnt/bulk/nfs/probe",
              "umount /mnt/bulk",
              "test -e /bulk-pool/nfs/probe",
          )
        '';
      };
    };
}
