{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.shell.zsh.enable =
      lib.mkEnableOption "Whether or not to use zsh as a preferred shell";
  };

  config = lib.mkIf config.mine.shell.zsh.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
