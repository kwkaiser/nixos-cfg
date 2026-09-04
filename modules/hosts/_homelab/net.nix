{ config, pkgs, ... }: {
  networking.hostId = "5d26a1e5";
  networking.hostName = "box";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 32555 ];
}
