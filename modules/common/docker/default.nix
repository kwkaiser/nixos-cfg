{ pkgs, config, lib, inputs, isDarwin, ... }: {
  options = {
    mine.docker.enable = lib.mkEnableOption "Whether or not to enable Docker";
  };

  config = lib.mkIf config.mine.docker.enable ({
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  } // lib.optionalAttrs isDarwin { homebrew.casks = [ "docker" ]; }
    // lib.optionalAttrs (!isDarwin) {
      virtualisation.docker = {
        enable = true;
        daemon.settings = {
          log-driver = "journald";
          log-opts = { max-file = "3"; };
        };
      };
      users.users.${config.mine.username}.extraGroups = [ "docker" ];
    });
}
