{ pkgs, lib, config, isDarwin, ... }: {
  options = {
    mine.ssh.enable = lib.mkEnableOption "Enables SSH and SSH agent";
  };

  config = lib.mkIf config.mine.ssh.enable {
    # Enable SSH service
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    # Enable SSH agent
    programs.ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };

  } // (if isDarwin then {
    # On Darwin, we need to use the launchd service instead
    launchd.user.agents.ssh-agent = {
      serviceConfig = {
        ProgramArguments =
          [ "/usr/bin/ssh-agent" "-D" "-a" "/tmp/ssh-agent.socket" ];
        RunAtLoad = true;
        KeepAlive = true;
      };
    };
  } else
    { });
}
