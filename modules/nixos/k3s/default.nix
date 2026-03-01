{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    mine.k3s.enable =
      lib.mkEnableOption "Enables k3s Kubernetes control server";
  };

  config = lib.mkIf config.mine.k3s.enable {
    services.k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [
        # Use native nftables mode for kube-proxy instead of iptables compatibility layer
        # This avoids the "Couldn't load match 'mark'" error on NixOS
        "--kube-proxy-arg=proxy-mode=nftables"
        "--kubelet-arg=allowed-unsafe-sysctls=net.ipv6.conf.all.forwarding,net.ipv4.conf.all.src_valid_mark,net.ipv6.conf.all.disable_ipv6,net.ipv4.ip_forward"
      ];
    };

    # Netfilter modules required for k3s with nftables kube-proxy mode
    boot.kernelModules = [
      "nf_conntrack"
      "br_netfilter"
      "nf_tables"
      "nft_chain_nat"
      "nft_compat"
    ];

    # Open firewall for k3s API and NodePort range
    networking.firewall.allowedTCPPorts = [6443 8080 30080 30443];

    # Add kubectl and nftables for k3s compatibility
    environment.systemPackages = with pkgs; [
      kubectl
      nftables # Required for kube-proxy nftables mode
      iptables # Still needed for flannel and other components
    ];
  };
}
