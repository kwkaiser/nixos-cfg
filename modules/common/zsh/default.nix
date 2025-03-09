{ pkgs, config, lib, inputs, ... }: {

  config = lib.mkIf config.mine.zsh.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
