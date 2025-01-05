{ config, pkgs, ... }: {
  networking.hostName = "vm";
  networking.networkmanager.enable = true;
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
}
