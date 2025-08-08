{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.docker.enable = lib.mkEnableOption "Whether or not to enable Docker";
  };

  config = lib.mkIf config.mine.docker.enable {
    # Enable Docker
    virtualisation.docker.enable = true;

    # Add user to docker group
    users.users.${config.mine.username}.extraGroups = [ "docker" ];

    # Home manager configuration
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
