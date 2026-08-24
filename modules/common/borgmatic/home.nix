{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    borgbackup
    borgmatic
  ];
}
