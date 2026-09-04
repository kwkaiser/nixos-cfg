{ ... }: {
  networking.hostName = "homelab-vps";
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
  ];

  # Linode silently blackholes return traffic to this host's IPv6 privacy
  # (RFC 4941 temporary) address - only the stable SLAAC address they
  # actually track works. Outbound IPv6 connections default to using the
  # temporary address as source (net.ipv6.conf.*.use_tempaddr=2), which
  # made every IPv6 connection either hang or crawl at a tiny fraction of
  # real throughput (confirmed: same transfer went from ~0.1MB/s to
  # ~6MB/s once forced onto the stable address). Disabling temp addresses
  # makes the stable address the only outbound source, fixing this for
  # both host-level and pod-egress (SNAT'd through the host) IPv6 traffic.
  networking.tempAddresses = "disabled";
}
