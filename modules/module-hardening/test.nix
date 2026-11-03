{
  config.nixos.modules.module-hardening =
    {
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf (config.mine.vmTest.tests.module-hardening or false) {
        mine.vmTest.scripts.module-hardening = ''
          machine.succeed("test \"$(sysctl -n kernel.unprivileged_bpf_disabled)\" = 1")
          machine.fail("modprobe sctp")
          client.fail("timeout 5 bash -c '</dev/tcp/${config.networking.hostName}/2049'")
        '';
      };
    };
}
