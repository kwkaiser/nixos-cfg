{ pkgs, config, ... }: {
  programs = {
    kitty = {
      enable = true;
      settings = {
        foreground = "#${config.colorScheme.palette.base05}";
        background = "#${config.colorScheme.palette.base00}";
      };
      extraConfig = ''
        confirm_os_window_close 0 
      '';
    };

  };
}
