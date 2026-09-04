{ mkModuleOption, ... }:
let
  ignorePatterns = [
    ".DS_Store"
    "._*"
    ".fseventsd"
    ".Trashes"
    ".Spotlight-V100"
    ".TemporaryItems"
  ];

  deviceIds = {
    phone = "C2OL7VB-VVCL6CM-2ZLO7N4-RLTP7GO-EN3EZSD-QPZL3XC-VTI7IUC-BDDCEAV";
    desktop = "GUNDSXG-DIIM4AU-IF2MLGU-TAGH3RP-X7AJELO-VJAEZAF-4VMV4QI-SQIT2AQ";
    server = "KCLNUZ7-P2YEIO4-WNZ7O6L-TXWD3VI-TETMH45-GQJKLNC-LMEFDIV-B7XBFAM";
    pallet-macbook = "6JZGMBT-TX43LZJ-L7VCKGI-ZTSAJNV-GFAPC66-ENZ5UDE-SGT2XQV-I3RWFA7";
  };

  allDevices = builtins.mapAttrs (name: id: { inherit id; }) deviceIds;

  # Who each device is allowed to connect to. pallet-macbook (work laptop,
  # employer-controlled) only talks to server, so cutting it off is a single
  # edit here rather than something enforced per-device.
  topology = {
    phone = [ "desktop" "server" ];
    desktop = [ "phone" "server" ];
    server = [ "phone" "desktop" "pallet-macbook" ];
    pallet-macbook = [ "server" ];
  };

  mkHmModule = selfDevice: { lib, ... }:
    let
      allowedPeers = topology.${selfDevice} or [ ];
      folderDevices = builtins.filter (d: builtins.elem d allowedPeers) (builtins.attrNames allDevices);
    in
    {
      services.syncthing = {
        enable = true;
        settings = {
          devices = lib.filterAttrs (name: _: builtins.elem name allowedPeers) allDevices;
          folders = {
            keys = {
              id = "5plku-9azor";
              path = "~/Documents/keys";
              devices = folderDevices;
              inherit ignorePatterns;
            };
            notes = {
              id = "m4rpl-gqmhy";
              path = "~/Documents/notes";
              devices = folderDevices;
              inherit ignorePatterns;
            };
          };
        };
      };
    };

  featureOptions = { lib, ... }: {
    options.mine.syncthing.deviceName = lib.mkOption {
      type = lib.types.str;
      description = "This host's syncthing device name. Determines which peers it's allowed to connect to, per the edges declared in ./syncthing.nix.";
    };
  };
in
{
  options.nixos.modules.syncthing = mkModuleOption { };
  options.darwin.modules.syncthing = mkModuleOption { };

  config.nixos.modules.syncthing = { config, ... }: {
    imports = [ featureOptions ];
    home-manager.users.${config.mine.username}.imports = [ (mkHmModule config.mine.syncthing.deviceName) ];
  };
  config.darwin.modules.syncthing = { config, ... }: {
    imports = [ featureOptions ];
    home-manager.users.${config.mine.username}.imports = [ (mkHmModule config.mine.syncthing.deviceName) ];
  };
}
