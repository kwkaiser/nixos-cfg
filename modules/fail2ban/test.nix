{
  config.nixos.modules.fail2ban =
    {
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf (config.mine.vmTest.tests.fail2ban or false) {
        users.users.${config.mine.username}.openssh.authorizedKeys.keys = [
          config.mine.vmTest.sshKeys.snakeOilPublicKey
        ];

        services.openssh.settings.PerSourcePenalties = "no";

        mine.vmTest.scripts.fail2ban = ''
          host = "${config.networking.hostName}"
          ssh = "ssh -i /root/id -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=10"
          machine.wait_for_unit("sshd.service")
          machine.wait_for_unit("fail2ban.service")
          machine.wait_until_succeeds("fail2ban-client status sshd", timeout=120)

          for _ in range(6):
              client.fail(f"{ssh} nosuchuser@{host} true", timeout=60)
          machine.wait_until_succeeds(r"fail2ban-client status sshd | grep -qE 'Currently banned:\s+1'", timeout=120)
          client.fail(f"{ssh} ${config.mine.username}@{host} true", timeout=60)
          machine.succeed("fail2ban-client unban --all")
          client.succeed(f"{ssh} ${config.mine.username}@{host} true", timeout=60)
        '';
      };
    };
}
