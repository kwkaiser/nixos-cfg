{ pkgs, lib, config, inputs, home, bconfig, ... }: {
  home.packages = with pkgs; [ rofi ];
  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "drun";
      display-drun = "Run";
      sidebar-mode = false;
    };
  };
}
