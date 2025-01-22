{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.editor.neovim.enable =
      lib.mkEnableOption "Whether to enable neovim as the preferred editor";
  };

  config = {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
