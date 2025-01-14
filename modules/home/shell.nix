{ config, pkgs, lib, ... }: {
  options = {
    home.shell.zsh = lib.mkEnableOption "should use zsh as home shell";
  };

  config = lib.mkIf config.home.shell.zsh.enable {
    home.packages = [ pkgs.zsh ];
    programs.zsh.enable = true;
  };

}
