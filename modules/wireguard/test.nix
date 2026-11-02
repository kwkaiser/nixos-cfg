{
  config.nixos.modules.wireguard = {
    config,
    lib,
    ...
  }: {
    config = lib.mkIf (config.mine.vmTest.tests.wireguard or false) {
      networking.wireguard.interfaces.wg0.generatePrivateKeyFile = true;

      mine.vmTest.scripts.wireguard = ''
        machine.wait_for_unit("wireguard-wg0.service")
        machine.succeed("ip link show wg0")
      '';
    };
  };
}
