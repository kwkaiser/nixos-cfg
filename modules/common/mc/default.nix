{
  lib,
  config,
  ...
}: {
  options = {
    mine.mc.enable = lib.mkEnableOption "Minecraft setup";
  };

  config = lib.mkIf config.mine.mc.enable {
    # Home manager config
    home-manager.users.${config.mine.username} = {imports = [./home.nix];};
  };
}
