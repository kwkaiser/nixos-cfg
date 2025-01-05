{ config, pkgs, ... }: {
  networking.firewall.allowedTCPPorts = [ 6443 ];
  networking.firewall.allowedUDPPorts = [ 8472 ];
  services.k3s.enable = true;
  services.k3s.role = "server";
}
