{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.dev.node.enable =
      lib.mkEnableOption "Whether to enable a node environment";
  };

  config = {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
