{ pkgs, lib, config, bconfig, ... }: {
  services.gnome-keyring = {
    enable = true;
    # SSH component removed to avoid conflict with programs.ssh.startAgent
    components = [ "pkcs11" "secrets" ];
  };
}

