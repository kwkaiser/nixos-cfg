{
  config.nixos.modules.tailnet-dns =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.mine.vmTest.tests.tailnet-dns or false) {
        mine.vmTest.scripts.tailnet-dns = ''
          machine.wait_for_unit("tailscaled.service")
          machine.wait_for_unit("dnsmasq.service")
        '';
      };
    };
}
