{ mkModuleOption, ... }:
{
  options.nixos.modules.node-exporter = mkModuleOption { };

  config.nixos.modules.node-exporter = {
    services.prometheus.exporters.node = {
      enable = true;
      port = 9100;
      enabledCollectors = [
        "systemd"
        "processes"
      ];
    };

    networking.firewall.interfaces."cni0".allowedTCPPorts = [ 9100 ];
  };
}
