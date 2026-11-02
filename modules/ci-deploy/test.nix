{
  config.nixos.modules.ci-deploy =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.mine.vmTest.tests.ci-deploy or false) {
        mine.ciDeploy.authorizedKey = config.mine.vmTest.sshKeys.snakeOilPublicKey;
        system.switch.enable = true;

        mine.vmTest.scripts.ci-deploy = ''
          ssh = "ssh -i /root/id -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=30 -o ServerAliveInterval=15 -o ServerAliveCountMax=4"
          machine.wait_for_unit("sshd.service")
          client.fail(f"{ssh} ci-deploy@${config.networking.hostName} /etc/passwd", timeout=300)
          client.fail(f"{ssh} ci-deploy@${config.networking.hostName} 'id; true'", timeout=300)
          current = machine.succeed("readlink -f /run/current-system", timeout=60).strip()
          client.succeed(f"{ssh} ci-deploy@${config.networking.hostName} {current}", timeout=900)
        '';
      };
    };
}
