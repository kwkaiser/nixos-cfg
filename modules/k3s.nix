{ mkModuleOption, ... }:
{
  options.nixos.modules.k3s = mkModuleOption { };

  config.nixos.modules.k3s = { pkgs, ... }: {
    services.k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [
        # Use native nftables mode for kube-proxy instead of iptables compatibility layer
        # This avoids the "Couldn't load match 'mark'" error on NixOS
        "--kube-proxy-arg=proxy-mode=nftables"
        "--kubelet-arg=allowed-unsafe-sysctls=net.ipv6.conf.all.forwarding,net.ipv4.conf.all.src_valid_mark,net.ipv6.conf.all.disable_ipv6,net.ipv4.ip_forward"
        # Widen the NodePort range so Services can request nodePort 80/443
        # directly, instead of needing a host-level port-redirect hack to
        # get standard ports - kube-proxy's own NodePort path is what
        # correctly marks traffic as netpol-allowed, which a bolted-on
        # REDIRECT/DNAT trick doesn't.
        "--kube-apiserver-arg=service-node-port-range=80-32767"
        # Nothing in the app repo defines an Ingress or LoadBalancer Service
        # (everything is exposed via NodePort), so the bundled ingress
        # controller and service load balancer are unused overhead.
        "--disable=traefik"
        "--disable=servicelb"
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
    networking.firewall.allowedTCPPorts = [
      6443
      8080
      30080
      30443
    ];

    # Add kubectl and nftables for k3s compatibility
    environment.systemPackages = with pkgs; [
      kubectl
      nftables # Required for kube-proxy nftables mode
      iptables # Still needed for flannel and other components
    ];
  };
}
