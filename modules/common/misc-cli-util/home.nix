{pkgs, ...}: {
  home.packages = with pkgs; [
  ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
