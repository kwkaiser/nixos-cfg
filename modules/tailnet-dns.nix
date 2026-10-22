{ mkModuleOption, ... }:
{
  options.nixos.modules.tailnet-dns = mkModuleOption { };

  config.nixos.modules.tailnet-dns = { config, lib, ... }: {
    options.mine.tailnetDns = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "kwkaiser.io";
        description = "Domain whose names all resolve to this host's tailnet address";
      };

      address = lib.mkOption {
        type = lib.types.str;
        description = "This host's tailnet IPv4 address";
      };
    };

    config = {
      services.dnsmasq = {
        enable = true;
        resolveLocalQueries = false;
        settings = {
          interface = "tailscale0";
          bind-dynamic = true;
          no-resolv = true;
          no-hosts = true;
          local = "/${config.mine.tailnetDns.domain}/";
          address = "/${config.mine.tailnetDns.domain}/${config.mine.tailnetDns.address}";
        };
      };

      networking.firewall.interfaces.tailscale0 = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
    };
  };
}
