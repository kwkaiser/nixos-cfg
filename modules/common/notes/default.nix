{ pkgs, lib, config, ... }: {
  options = {
    mine.notes = {
      enable = lib.mkEnableOption "Enables obsidian for note taking";
      untrusted = lib.mkEnableOption "Enables cryptomator for encrypted notes";
    };
  };

  config = lib.mkIf config.mine.notes.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
