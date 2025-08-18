{ pkgs, config, lib, inputs, isDarwin, ... }: {
  options = {
    mine.docker.enable = lib.mkEnableOption "Whether or not to enable Docker";
  };

  config = lib.mkIf config.mine.docker.enable (if isDarwin then
    {
      # Darwin-specific Docker configuration (if any)
    }
  else {
    virtualisation.docker = { enable = true; };
    users.users.${config.mine.username}.extraGroups = [ "docker" ];
  });
}
