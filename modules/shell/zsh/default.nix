{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.shell.zsh.enabled =
      lib.mkEnableOption "Whether or not to use zsh as a preferred shell";
  };

  config = lib.mkIf config.mine.shell.zsh.enabled {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
