{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.neovim.enable =
      lib.mkEnableOption "Whether to enable neovim as the preferred editor";
  };

  config = lib.mkIf config.mine.neovim.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
