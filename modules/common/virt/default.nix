{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.virt.enable =
      lib.mkEnableOption "Whether or not virtualization is enabled";
  };

  config = lib.mkIf config.mine.virt.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
