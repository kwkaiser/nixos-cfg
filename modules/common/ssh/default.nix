{
  lib,
  config,
  isDarwin,
  ...
}: {
  options = {
    mine.ssh.enable = lib.mkEnableOption "Enables SSH and SSH agent";
  };

  config = lib.mkIf config.mine.ssh.enable {
    # Enable SSH service
    services.openssh.enable = true;

    # Enable SSH agent
    programs.ssh = {
      extraConfig = ''
        AddKeysToAgent yes

        Host homelab-vm
        HostName localhost
        User kwkaiser
        StrictHostKeyChecking no
        Port 2222
      '';
    } // lib.optionalAttrs (!isDarwin) {
      startAgent = true;
    };

    home-manager.users.${config.mine.username} = {imports = [./home.nix];};
  };
}
