{pkgs, ...}: {
  home.packages = with pkgs; [
    terminal-rain-lightning
    pipes
  ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
