{
  pkgs,
  lib,
  config,
  isDarwin,
  ...
}:
{
  options = {
    mine.notes.enable = lib.mkEnableOption "Enables obsidian for note taking";
  };

  config = lib.mkIf config.mine.notes.enable (
    {
      home-manager.users.${config.mine.username} = {
        imports = [ ./home.nix ];
      };
    }
    // lib.optionalAttrs isDarwin {
      homebrew.casks = [
        "veracrypt-fuse-t"
        "macfuse"
      ];
    }
  );
}
