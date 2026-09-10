{
  mkModuleOption,
  lib,
  ...
}: let
  listenPort = 51820;

  hosts = {
    homelab-vps = {
      publicKey = "/n3rcGG+jC5kPlmhB18V8DRtSIviHO6MmBUXxpWzsyQ=";
      address = "10.100.0.1";
      address6 = "fd10:100::1";
      endpoint = "kwkaiser.io:51820";
      externalInterface = "enp1s0";
      allowedIPs = [];
    };
    # homelab = {
    #   publicKey = "REPLACE_WITH_homelab_PUBLIC_KEY";
    #   address = "10.100.0.2";
    #   address6 = "fd10:100::2";
    #   endpoint = null;
    #   externalInterface = null;
    #   allowedIPs = [ "192.168.2.0/24" ];
    # };
    # desktop = {
    #   publicKey = "REPLACE_WITH_desktop_PUBLIC_KEY";
    #   address = "10.100.0.3";
    #   address6 = "fd10:100::3";
    #   endpoint = null;
    #   externalInterface = null;
    #   allowedIPs = [ ];
    # };
    personal-macbook = {
      publicKey = "30CDzowfLVxg3oz29A1AOGZqmbdIzezKCu+wYA9N1m4=";
      address = "10.100.0.4";
      address6 = "fd10:100::4";
      endpoint = null;
      externalInterface = null;
      allowedIPs = [];
    };
  };

  topology = {
    personal-macbook = ["homelab-vps"];
  };

  peersOf = self: let
    accesses = topology.${self} or [];
    accessedBy = lib.attrNames (lib.filterAttrs (name: edges: builtins.elem self edges) topology);
  in
    lib.unique (accesses ++ accessedBy);

  peersFor = self:
    map
    (
      name: let
        h = hosts.${name};
      in {
        publicKey = h.publicKey;
        allowedIPs =
          if h.endpoint != null
          then ["0.0.0.0/0" "::/0"]
          else ["${h.address}/32" "${h.address6}/128"] ++ h.allowedIPs;
        endpoint = h.endpoint;
        persistentKeepalive =
          if hosts.${self}.endpoint == null
          then 25
          else null;
      }
    )
    (peersOf self);
in {
  options.nixos.modules.wireguard = mkModuleOption {};
  options.darwin.modules.wireguard = mkModuleOption {};

  config.nixos.modules.wireguard = {
    config,
    pkgs,
    ...
  }: let
    self = hosts.${config.mine.flakeHost} or null;
    isGateway = self != null && self.endpoint != null;
  in {
    home-manager.users.${config.mine.username}.home.packages = [pkgs.wireguard-tools];

    networking.firewall.allowedUDPPorts = lib.optional isGateway listenPort;

    networking.nat = {
      enable = isGateway;
      enableIPv6 = isGateway;
      internalInterfaces = lib.optional isGateway "wg0";
      externalInterface = lib.mkIf isGateway self.externalInterface;
    };

    networking.wireguard.interfaces = lib.optionalAttrs (self != null) {
      wg0 = {
        ips = ["${self.address}/24" "${self.address6}/64"];
        inherit listenPort;
        privateKeyFile = "/etc/wireguard/wg0-private-key";
        peers = peersFor config.mine.flakeHost;
      };
    };
  };

  config.darwin.modules.wireguard = {
    config,
    pkgs,
    ...
  }: let
    self = hosts.${config.mine.flakeHost} or null;
  in {
    home-manager.users.${config.mine.username}.home.packages = [pkgs.wireguard-tools];

    networking.wg-quick.interfaces = lib.optionalAttrs (self != null) {
      wg0 = {
        address = ["${self.address}/24" "${self.address6}/64"];
        autostart = false;
        inherit listenPort;
        privateKeyFile = "/etc/wireguard/wg0-private-key";
        peers = peersFor config.mine.flakeHost;
      };
    };
  };
}
