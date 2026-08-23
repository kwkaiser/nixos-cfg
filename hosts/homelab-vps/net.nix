{ ... }: {
  networking.hostName = "homelab-vps";
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
}
