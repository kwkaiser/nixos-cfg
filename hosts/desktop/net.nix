{ config, pkgs, ... }: {
  networking.hostId = "22a4d930";
  networking.hostName = "vm";
  networking.networkmanager.enable = true;
  mine.ssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 ];
}
