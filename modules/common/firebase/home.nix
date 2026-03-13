{pkgs, ...}: {
  home.packages = with pkgs; [
    firebase-tools
  ];
}
