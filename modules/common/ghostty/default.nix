{ pkgs, lib, config, ... }: {

  options = {
    mine.ghostty.enable = lib.mkEnableOption "Enables ghostty as a used terminal";
  };

  config = lib.mkIf config.mine.ghostty.enable {
    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
