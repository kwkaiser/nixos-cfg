{ pkgs, lib, config, isDarwin, ... }: {
  options = {
    mine.notes = {
      enable = lib.mkEnableOption "Enables obsidian for note taking";
      untrusted = lib.mkEnableOption "Enables cryptomator for encrypted notes";
    };
  };

  config = lib.mkIf config.mine.notes.enable (lib.mkMerge [
    {
      home-manager.users.${config.mine.username} = {
        imports = [ ./home.nix ];
      };
    }
    (lib.mkIf (isDarwin && config.mine.notes.untrusted) {
      homebrew.casks = [ "cryptomator" ];
    })
  ]);
}
