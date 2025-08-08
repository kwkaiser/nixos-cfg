{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.zsh.enable =
      lib.mkEnableOption "Whether or not to use zsh as a preferred shell";
  };

  config = lib.mkIf config.mine.zsh.enable {
    # Enable zsh system-wide
    programs.zsh.enable = true;

    # Set zsh as the default shell for the user
    users.users.${config.mine.username}.shell = pkgs.zsh;

    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
