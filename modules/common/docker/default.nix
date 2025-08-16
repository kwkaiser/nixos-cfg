{ pkgs, config, lib, inputs, isDarwin, ... }: {
  options = {
    mine.docker.enable = lib.mkEnableOption "Whether or not to enable Docker";
  };

  config = lib.mkIf config.mine.docker.enable {
    # Stub
  }
  // (if isDarwin then {
  } else
    { 
      virtualisation.docker = { enable = true; };
      users.users.${config.mine.username}.extraGroups = [ "docker" ];
    });
}
