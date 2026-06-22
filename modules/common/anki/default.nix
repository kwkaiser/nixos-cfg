{
  config,
  lib,
  ...
}: {
  options = {
    mine.anki.enable = lib.mkEnableOption "Whether or not to enable anki";
  };

  config = lib.mkIf config.mine.anki.enable {
    home-manager.users.${config.mine.username} = {
      imports = [./home.nix];
    };
  };
}
