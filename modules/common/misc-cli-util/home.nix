{pkgs, ...}: {
  home.packages = with pkgs; [
    whisky
  ];
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
