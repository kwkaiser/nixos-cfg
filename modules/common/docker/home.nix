{
  config,
  pkgs,
  bconfig,
  ...
}:
{
  home.packages = with pkgs; [
    docker-compose
  ];
}
