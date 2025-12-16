{
  pkgs,
  lib,
  config,
  isDarwin,
  ...
}:
{
  options = {
    mine.notes = {
      enable = lib.mkEnableOption "Enables obsidian for note taking";
      untrusted = lib.mkEnableOption "Enables veracrypt-fuse-t for encrypted notes";
    };
  };

  config =
    lib.mkIf config.mine.notes.enable {
      home-manager.users.${config.mine.username} = {
        imports = [ ./home.nix ];
      };
    }
    // (
      if isDarwin then
        {
          homebrew.casks = lib.mkIf config.mine.notes.untrusted [
            "veracrypt-fuse-t"
            "macfuse"
            "osxfuse"
          ];
        }
      else
        { }
    );
}
