{ pkgs, lib, config, ... }: {

  options = {
    mine.k3s.enable =
      lib.mkEnableOption "Enables k3s Kubernetes control server";
  };

  config = lib.mkIf config.mine.k3s.enable {
    services.k3s = {
      enable = true;
      role = "server";
      extraFlags = ''
        --kubelet-arg=allowed-unsafe-sysctls=net.ipv6.conf.all.forwarding,net.ipv4.conf.all.src_valid_mark,net.ipv6.conf.all.disable_ipv6,net.ipv4.ip_forward
      '';
    };

    networking.firewall.allowedTCPPorts = [ 6443 8080 ];

    # Add kubectl for convenience
    environment.systemPackages = with pkgs; [ kubectl ];
  };
}
