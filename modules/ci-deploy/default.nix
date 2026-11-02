{ mkModuleOption, ... }:
{
  options.nixos.modules.ci-deploy = mkModuleOption { };

  config.nixos.modules.ci-deploy =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mine.ciDeploy;

      switchScript = pkgs.writeShellApplication {
        name = "ci-deploy-switch";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.systemd
          config.nix.package
        ];
        text = ''
          system="''${1:-}"
          if [[ ! "$system" =~ ^/nix/store/[a-z0-9]{32}-nixos-system-${config.system.name}-[A-Za-z0-9._+-]+$ ]] \
            || [ ! -x "$system/bin/switch-to-configuration" ]; then
            echo "refusing to deploy '$system'" >&2
            exit 1
          fi

          if [ "$(readlink -f /run/current-system)" = "$system" ]; then
            echo "$system is already the running system"
            exit 0
          fi

          nix-env --profile /nix/var/nix/profiles/system --set "$system"
          exec systemd-run --unit="ci-deploy-$(date +%s)" --collect --wait --pipe --quiet \
            "$system/bin/switch-to-configuration" switch
        '';
      };

      entryScript = pkgs.writeShellApplication {
        name = "ci-deploy";
        text = ''
          exec /run/wrappers/bin/sudo ${lib.getExe switchScript} "''${SSH_ORIGINAL_COMMAND:-}"
        '';
      };
    in
    {
      options.mine.ciDeploy.authorizedKey = lib.mkOption {
        type = lib.types.str;
        default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTG5X2Pm3rVbhm1d+R4VpXF+FBsLsErkbNDZJNPRsK4 ci-deploy-homelab-vps";
        description = "Public half of the homelab-vps CI deploy keypair. Accepted only for the nix commands needed to upgrade homelab-vps: setting the system profile to an already-built nixos-system-homelab-vps store path and running its switch-to-configuration. Private half lives in secretspec as HOMELAB_VPS_DEPLOY_KEY and in the Gitea secret of the same name.";
      };

      config = {
        users.groups.ci-deploy = { };

        users.users.ci-deploy = {
          isSystemUser = true;
          group = "ci-deploy";
          shell = pkgs.bash;
          openssh.authorizedKeys.keys = [
            ''restrict,command="${lib.getExe entryScript}" ${cfg.authorizedKey}''
          ];
        };

        security.sudo.extraRules = [
          {
            users = [ "ci-deploy" ];
            commands = [
              {
                command = lib.getExe switchScript;
                options = [ "NOPASSWD" ];
              }
            ];
          }
        ];
      };
    };
}
