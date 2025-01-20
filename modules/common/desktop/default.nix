{ pkgs, config, lib, inputs, ... }: {
  home-manager.users.${config.mine.username} = { imports = [ ./hm.nix ]; };
}
