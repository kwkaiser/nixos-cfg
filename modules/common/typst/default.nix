{
  lib,
  config,
  ...
}: {
  options = {
    mine.typst.enable = lib.mkEnableOption "Whether typst is used";
  };

  config = lib.mkIf config.mine.typst.enable {
    # Home manager config
    home-manager.users.${config.mine.username} = {imports = [./home.nix];};
  };
}
