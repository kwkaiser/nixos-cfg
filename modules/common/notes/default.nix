{ pkgs, lib, config, ... }: {
  options = {
    mine.notes.enable = lib.mkEnableOption "Enables obsidian for note taking";
  };

  config = lib.mkIf config.mine.notes.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
