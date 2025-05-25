{ config, pkgs, ... }: {
  networking.hostId = "007f0101";
  networking.hostName = "desktop";
  networking.networkmanager.enable = true;
  mine.ssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 ];
}
