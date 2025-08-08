{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.docker.enable = lib.mkEnableOption "Whether or not to enable Docker";
  };

  config = lib.mkIf config.mine.docker.enable {
    virtualisation.docker = { enable = true; };

    users.users.${config.mine.username}.extraGroups = [ "docker" ];
  };
}
