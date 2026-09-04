{ mkModuleOption, ... }:
let
  hmModule = { ... }: {
    services.gnome-keyring = {
      enable = true;
      # SSH component removed to avoid conflict with programs.ssh.startAgent
      components = [ "pkcs11" "secrets" ];
    };
  };
in
{
  options.nixos.modules.keyring = mkModuleOption { };

  config.nixos.modules.keyring = { pkgs, config, lib, ... }: {
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

    home-manager.users.${config.mine.username}.imports = [ hmModule ];
  };
}
