{ pkgs, lib, config, inputs, home, bconfig, ... }: {
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };
}
