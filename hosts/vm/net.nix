{ config, pkgs, ... }: {
  networking.hostId = "22a4d930";
  networking.hostName = "vm";
  networking.networkmanager.enable = true;
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
}
