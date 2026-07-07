{pkgs, ...}: {
  home.packages = with pkgs; [
    terminal-rain-lightning
    pipes
    gnumake
  ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
