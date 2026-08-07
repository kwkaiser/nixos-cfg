{ pkgs, config, lib, ... }: {
  options = {
    mine.secretspec.enable = lib.mkEnableOption "Whether or not to enable secretspec with a personal kdbx provider";
  };

  config = lib.mkIf config.mine.secretspec.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
