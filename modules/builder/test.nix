{
  config.nixos.modules.builder =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.mine.vmTest.tests.builder or false) {
        mine.vmTest.scripts.builder = ''
          machine.succeed("id ${config.mine.builder.sshUser}")
          machine.succeed("test -e /proc/sys/fs/binfmt_misc/aarch64-linux")
        '';
      };
    };
}
