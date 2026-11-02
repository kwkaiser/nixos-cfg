{
  config.nixos.modules.ci-deploy =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.mine.vmTest.tests.ci-deploy or false) {
        mine.ciDeploy.authorizedKey = config.mine.vmTest.sshKeys.snakeOilPublicKey;

        mine.vmTest.scripts.ci-deploy = ''
          ssh = "ssh -i /root/id -o BatchMode=yes -o StrictHostKeyChecking=no"
          machine.wait_for_unit("sshd.service")
          client.fail(f"{ssh} ci-deploy@${config.networking.hostName} /etc/passwd")
          client.fail(f"{ssh} ci-deploy@${config.networking.hostName} 'id; true'")
          current = machine.succeed("readlink -f /run/current-system").strip()
          client.succeed(f"{ssh} ci-deploy@${config.networking.hostName} {current}")
        '';
      };
    };
}
