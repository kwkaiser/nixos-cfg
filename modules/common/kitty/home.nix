{ pkgs, config, ... }: {
  programs = {
    kitty = {
      enable = true;
      extraConfig = ''
        confirm_os_window_close 0 
      '';
      settings = {
        foreground = "#${config.colorScheme.palette.base05}";
        background = "#${config.colorScheme.palette.base00}";
      };
    };

  };
}
