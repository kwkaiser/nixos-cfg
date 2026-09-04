{ config, pkgs, ... }: {
  networking.hostId = "007f0101";
  networking.hostName = "desktop";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    80
  ];
  networking.interfaces.enp8s0.wakeOnLan.enable = true;

  # IPv6 upstream is dead on this network (blackholed, not rejected), but
  # getaddrinfo still returns AAAA first. Apps without Happy Eyeballs (gcloud's
  # python http stack, notably) stall for minutes per connection before
  # falling back to IPv4. Prefer IPv4-mapped addresses so it's tried first.
  environment.etc."gai.conf".text = ''
    precedence ::ffff:0:0/96 100
  '';
}
