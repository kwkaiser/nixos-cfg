{ mkModuleOption, lib, ... }:
let
  listenPort = 51820;

  hosts = {
    homelab-vps = {
      publicKey = "REPLACE_WITH_homelab-vps_PUBLIC_KEY";
      address = "10.100.0.1";
      endpoint = "REPLACE_WITH_homelab-vps_PUBLIC_ENDPOINT:51820";
      allowedIPs = [ ];
    };
    homelab = {
      publicKey = "REPLACE_WITH_homelab_PUBLIC_KEY";
      address = "10.100.0.2";
      endpoint = null;
      allowedIPs = [ "192.168.2.0/24" ];
    };
    desktop = {
      publicKey = "REPLACE_WITH_desktop_PUBLIC_KEY";
      address = "10.100.0.3";
      endpoint = null;
      allowedIPs = [ ];
    };
    personal-macbook = {
      publicKey = "REPLACE_WITH_personal-macbook_PUBLIC_KEY";
      address = "10.100.0.4";
      endpoint = null;
      allowedIPs = [ ];
    };
    work-macbook = {
      publicKey = "REPLACE_WITH_work-macbook_PUBLIC_KEY";
      address = "10.100.0.5";
      endpoint = null;
      allowedIPs = [ ];
    };
  };

  peersFor =
    self:
    lib.mapAttrsToList
      (name: h: {
        publicKey = h.publicKey;
        allowedIPs = [ "${h.address}/32" ] ++ h.allowedIPs;
        endpoint = h.endpoint;
        persistentKeepalive = if hosts.${self}.endpoint == null then 25 else null;
      })
      (lib.filterAttrs (name: _: name != self) hosts);
in
{
  options.nixos.modules.wireguard = mkModuleOption { };
  options.darwin.modules.wireguard = mkModuleOption { };

  config.nixos.modules.wireguard =
    { config, pkgs, ... }:
    {
      home-manager.users.${config.mine.username}.home.packages = [ pkgs.wireguard-tools ];

      networking.firewall.allowedUDPPorts = lib.optional (
        hosts.${config.mine.flakeHost}.endpoint != null
      ) listenPort;

      networking.wireguard.interfaces.wg0 = {
        ips = [ "${hosts.${config.mine.flakeHost}.address}/24" ];
        inherit listenPort;
        privateKeyFile = "/etc/wireguard/wg0-private-key";
        peers = peersFor config.mine.flakeHost;
      };
    };

  config.darwin.modules.wireguard =
    { config, pkgs, ... }:
    {
      home-manager.users.${config.mine.username}.home.packages = [ pkgs.wireguard-tools ];

      networking.wg-quick.interfaces.wg0 = {
        address = [ "${hosts.${config.mine.flakeHost}.address}/24" ];
        inherit listenPort;
        privateKeyFile = "/etc/wireguard/wg0-private-key";
        peers = peersFor config.mine.flakeHost;
      };
    };
}
