{
  lib,
  config,
  ...
}: {
  options = {
    mine.zotero.enable = lib.mkEnableOption "Whether zotero is used";
  };

  config = lib.mkIf config.mine.zotero.enable {
    # Home manager config
    home-manager.users.${config.mine.username} = {imports = [./home.nix];};
  };
}
