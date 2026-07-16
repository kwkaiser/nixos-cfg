{
  lib,
  config,
  isDarwin,
  ...
}: {
  options = {
    mine.ssh.enable = lib.mkEnableOption "Enables SSH and SSH agent";
    mine.ssh.server.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enables the sshd server (Remote Login on Darwin). Independent of the client config, since MDM-managed laptops may enforce this off.";
    };
  };

  config = lib.mkIf config.mine.ssh.enable {
    mine.ssh.server.enable = lib.mkDefault true;

    services.openssh.enable = config.mine.ssh.server.enable;

    programs.ssh =
      {
      }
      // lib.optionalAttrs (!isDarwin) {
        startAgent = true;
      };

    home-manager.users.${config.mine.username} = {imports = [./home.nix];};

    launchd.user.agents.ssh-config-guard = lib.mkIf isDarwin {
      serviceConfig = {
        ProgramArguments = [
          "${config.home-manager.users.${config.mine.username}.home.activationPackage}/activate"
        ];
        EnvironmentVariables = {
          HOME = config.mine.homeDir;
          USER = config.mine.username;
          LOGNAME = config.mine.username;
        };
        WatchPaths = ["${config.mine.homeDir}/.ssh/config"];
        RunAtLoad = true;
        StandardOutPath = "${config.mine.homeDir}/Library/Logs/ssh-config-guard.log";
        StandardErrorPath = "${config.mine.homeDir}/Library/Logs/ssh-config-guard.log";
      };
    };
  };
}
