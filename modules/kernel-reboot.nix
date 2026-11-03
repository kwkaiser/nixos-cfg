{ mkModuleOption, ... }:
{
  options.nixos.modules.kernel-reboot = mkModuleOption { };

  config.nixos.modules.kernel-reboot =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mine.kernelReboot;

      rebootScript = pkgs.writeShellApplication {
        name = "kernel-reboot";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.systemd
        ];
        text = ''
          booted="$(readlink -f /run/booted-system/{initrd,kernel,kernel-modules})"
          current="$(readlink -f /run/current-system/{initrd,kernel,kernel-modules})"

          if [ "$booted" = "$current" ]; then
            echo "booted kernel matches current system; no reboot needed"
            exit 0
          fi

          if [ -n "$(systemctl list-units --state=active --plain --no-legend 'ci-deploy-*')" ]; then
            echo "ci-deploy switch in progress; skipping reboot"
            exit 0
          fi

          echo "kernel changed since boot; rebooting"
          systemctl reboot
        '';
      };
    in
    {
      options.mine.kernelReboot.onCalendar = lib.mkOption {
        type = lib.types.str;
        default = "Sun 02:00";
        description = "systemd OnCalendar expression for the window in which a reboot is allowed if the deployed kernel differs from the booted one.";
      };

      config = {
        systemd.services.kernel-reboot = {
          description = "Reboot if the deployed kernel differs from the booted kernel";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = lib.getExe rebootScript;
          };
        };

        systemd.timers.kernel-reboot = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = cfg.onCalendar;
            Persistent = false;
          };
        };
      };
    };
}
