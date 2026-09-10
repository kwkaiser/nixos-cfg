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
    # homelab = {
    #   publicKey = "REPLACE_WITH_homelab_PUBLIC_KEY";
    #   address = "10.100.0.2";
    #   endpoint = null;
    #   allowedIPs = [ "192.168.2.0/24" ];
    # };
    # desktop = {
    #   publicKey = "REPLACE_WITH_desktop_PUBLIC_KEY";
    #   address = "10.100.0.3";
    #   endpoint = null;
    #   allowedIPs = [ ];
    # };
    personal-macbook = {
      publicKey = "REPLACE_WITH_personal-macbook_PUBLIC_KEY";
      address = "10.100.0.4";
      endpoint = null;
      allowedIPs = [ ];
    };
  };

  topology = {
    personal-macbook = [ "homelab-vps" ];
  };

  peersOf =
    self:
    let
      accesses = topology.${self} or [ ];
      accessedBy = lib.attrNames (lib.filterAttrs (name: edges: builtins.elem self edges) topology);
    in
    lib.unique (accesses ++ accessedBy);

  peersFor =
    self:
    map
      (
        name:
        let
          h = hosts.${name};
        in
        {
          publicKey = h.publicKey;
          allowedIPs = if h.endpoint != null then [ "0.0.0.0/0" ] else [ "${h.address}/32" ] ++ h.allowedIPs;
          endpoint = h.endpoint;
          persistentKeepalive = if hosts.${self}.endpoint == null then 25 else null;
        }
      )
      (peersOf self);
in
{
  options.nixos.modules.wireguard = mkModuleOption { };
  options.darwin.modules.wireguard = mkModuleOption { };

  config.nixos.modules.wireguard =
    { config, pkgs, ... }:
    let
      self = hosts.${config.mine.flakeHost} or null;
    in
    {
      home-manager.users.${config.mine.username}.home.packages = [ pkgs.wireguard-tools ];

      networking.firewall.allowedUDPPorts = lib.optional (
        self != null && self.endpoint != null
      ) listenPort;

      networking.wireguard.interfaces = lib.optionalAttrs (self != null) {
        wg0 = {
          ips = [ "${self.address}/24" ];
          inherit listenPort;
          privateKeyFile = "/etc/wireguard/wg0-private-key";
          peers = peersFor config.mine.flakeHost;
        };
      };
    };

  config.darwin.modules.wireguard =
    { config, pkgs, ... }:
    let
      self = hosts.${config.mine.flakeHost} or null;
    in
    {
      home-manager.users.${config.mine.username}.home.packages = [ pkgs.wireguard-tools ];

      networking.wg-quick.interfaces = lib.optionalAttrs (self != null) {
        wg0 = {
          address = [ "${self.address}/24" ];
          inherit listenPort;
          privateKeyFile = "/etc/wireguard/wg0-private-key";
          peers = peersFor config.mine.flakeHost;
        };
      };
    };
}
