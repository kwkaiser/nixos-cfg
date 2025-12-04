{ pkgs, config, lib, ... }: {
  options = {
    mine.keyring.enable =
      lib.mkEnableOption "Enable standardized Linux keyring (GNOME Keyring)";
  };

  config = lib.mkIf config.mine.keyring.enable {
    services.gnome.gnome-keyring.enable = true;
    
    # Disable GCR SSH agent to avoid conflict with programs.ssh.startAgent
    services.gnome.gcr-ssh-agent.enable = false;

    environment.systemPackages = with pkgs; [
      gnome-keyring
      libsecret
      seahorse
    ];

    security.pam.services = {
      login.enableGnomeKeyring = true;
      greetd.enableGnomeKeyring = lib.mkIf config.services.greetd.enable true;
    };

    # services.dbus.packages = [ pkgs.gnome-keyring ];

    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
