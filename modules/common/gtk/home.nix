{ pkgs, lib, config, bconfig, ... }:
lib.mkIf bconfig.mine.gtk.enable {
  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };

  # Ensure icon cache is updated
  home.packages = with pkgs; [ papirus-icon-theme gnome-themes-extra ];
}
