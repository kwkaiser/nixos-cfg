{ pkgs, lib, config, isDarwin, ... }: {
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
      '';
    } // (if isDarwin then
      { }
    else {
      startAgent = true; # disabled because it conflicts with keyring
    });

    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
