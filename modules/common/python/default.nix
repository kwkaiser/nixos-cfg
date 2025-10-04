{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.python.enable =
      lib.mkEnableOption "Whether to enable Python development environment";
  };

  config = lib.mkIf config.mine.python.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
