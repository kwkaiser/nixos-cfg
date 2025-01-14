{ config, pkgs, lib, ... }: {
  options = {
    bingus.shell.zsh.enable = lib.mkEnableOption "should use zsh as home shell";
  };

  config = lib.mkIf config.bingus.shell.zsh.enable {
    home.packages = [ pkgs.zsh ];
    programs.zsh.enable = true;
  };

}
