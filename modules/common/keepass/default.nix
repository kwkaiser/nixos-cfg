{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.keepass.enable = lib.mkEnableOption "Whether or not to use keepassxc";
  };

  config = lib.mkIf config.mine.keepass.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
