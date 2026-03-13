{
  config,
  lib,
  ...
}: {
  options = {
    mine.neovim.enable =
      lib.mkEnableOption "Whether to enable neovim as the preferred editor";
  };

  config = lib.mkIf config.mine.neovim.enable {
    environment.variables.EDITOR = "nvim";
    home-manager.users.${config.mine.username} = {imports = [./home.nix];};
  };
}
