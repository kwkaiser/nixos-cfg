{
  config.nixos.modules.ssh = {
    config,
    lib,
    ...
  }: {
    config = lib.mkIf (config.mine.vmTest.tests.ssh or false) {
      users.users.${config.mine.username}.openssh.authorizedKeys.keys = [config.mine.vmTest.sshKeys.snakeOilPublicKey];

      mine.vmTest.scripts.ssh = ''
        ssh = "ssh -i /root/id -o BatchMode=yes -o StrictHostKeyChecking=no"
        machine.wait_for_unit("sshd.service")
        machine.wait_for_open_port(22)
        client.succeed(f"{ssh} ${config.mine.username}@${config.networking.hostName} true")
        client.succeed(f"{ssh} ${config.mine.username}@${config.networking.hostName} sudo -n true")
        client.fail(
            "ssh -o BatchMode=yes -o StrictHostKeyChecking=no "
            "-o PreferredAuthentications=password,keyboard-interactive ${config.mine.username}@${config.networking.hostName} true"
        )
      '';
    };
  };
}
