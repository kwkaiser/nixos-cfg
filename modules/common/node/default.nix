{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.node.enable =
      lib.mkEnableOption "Whether to enable a node environment";
  };

  config = lib.mkIf config.mine.node.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
