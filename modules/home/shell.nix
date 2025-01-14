{ config, pkgs, lib, ... }: {
  options = {
    homec.shell.zsh.enable = lib.mkEnableOption "should use zsh as home shell";
  };

  config = lib.mkIf config.homec.shell.zsh.enable {
    home.packages = [ pkgs.zsh ];
    programs.zsh.enable = true;
  };

}
