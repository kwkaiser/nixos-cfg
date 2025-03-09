{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.node.enable =
      lib.mkEnableOption "Whether or not to use node as a preferred shell";
  };

  config = lib.mkIf config.mine.node.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
