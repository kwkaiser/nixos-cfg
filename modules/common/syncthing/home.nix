{ selfDevice }:
{ config, pkgs, lib, ... }:
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
    desktop = "EN3PXUV-4CGWE5S-HJHI7ZE-BC2CH2X-TDV4SGQ-NL7XHRR-KBAEJEJ-74GQNQR";
    server = "KCLNUZ7-P2YEIO4-WNZ7O6L-TXWD3VI-TETMH45-GQJKLNC-LMEFDIV-B7XBFAM";
    pallet-macbook = "6JZGMBT-TX43LZJ-L7VCKGI-ZTSAJNV-GFAPC66-ENZ5UDE-SGT2XQV-I3RWFA7";
  };

  allDevices = lib.mapAttrs (name: id: { inherit id; }) deviceIds;

  # Who each device is allowed to connect to. pallet-macbook (work laptop,
  # employer-controlled) only talks to server, so cutting it off is a single
  # edit here rather than something enforced per-device.
  topology = {
    phone = [ "desktop" "server" ];
    desktop = [ "phone" "server" ];
    server = [ "phone" "desktop" "pallet-macbook" ];
    pallet-macbook = [ "server" ];
  };

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
}
