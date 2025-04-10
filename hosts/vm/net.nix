{ config, pkgs, ... }: {
  networking.hostId = "22a4d930";
  networking.hostName = "vm";
  networking.networkmanager.enable = true; 
}
