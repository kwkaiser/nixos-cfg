{pkgs, ...}: {
  home.packages = with pkgs; [
    terminal-rain-lightning
    pipes
    gnumake
    go-task
  ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
