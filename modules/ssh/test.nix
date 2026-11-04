{
  config.nixos.modules.ssh = {
    config,
    lib,
    ...
  }: {
    config = lib.mkIf (config.mine.vmTest.tests.ssh or false) {
      users.users.${config.mine.username}.openssh.authorizedKeys.keys = [config.mine.vmTest.sshKeys.snakeOilPublicKey];

      mine.vmTest.scripts.ssh = ''
        ssh = "ssh -i /root/id -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=30 -o ServerAliveInterval=15 -o ServerAliveCountMax=4"
        machine.wait_for_unit("sshd.service")
        machine.wait_for_open_port(22)
        sshd_config = machine.succeed("sshd -T").lower()
        for expected in ["kbdinteractiveauthentication no", "passwordauthentication no", "permitrootlogin no", "maxauthtries 3"]:
            assert expected in sshd_config, f"sshd -T missing '{expected}'"
        client.succeed(f"{ssh} ${config.mine.username}@${config.networking.hostName} true", timeout=300)
        client.succeed(f"{ssh} ${config.mine.username}@${config.networking.hostName} sudo -n true", timeout=300)
        client.fail(
            "ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=30 -o ServerAliveInterval=15 -o ServerAliveCountMax=4 "
            "-o PreferredAuthentications=password,keyboard-interactive ${config.mine.username}@${config.networking.hostName} true",
            timeout=300,
        )
      '';
    };
  };
}
