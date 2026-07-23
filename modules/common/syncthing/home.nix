{ config, pkgs, ... }:
let
  ignorePatterns = [
    ".DS_Store"
    "._*"
    ".fseventsd"
    ".Trashes"
    ".Spotlight-V100"
    ".TemporaryItems"
  ];
in
{
  services.syncthing = {
    enable = true;
    settings = {
      devices = {
        phone.id = "C2OL7VB-VVCL6CM-2ZLO7N4-RLTP7GO-EN3EZSD-QPZL3XC-VTI7IUC-BDDCEAV";
        desktop.id = "EN3PXUV-4CGWE5S-HJHI7ZE-BC2CH2X-TDV4SGQ-NL7XHRR-KBAEJEJ-74GQNQR";
        server.id = "KCLNUZ7-P2YEIO4-WNZ7O6L-TXWD3VI-TETMH45-GQJKLNC-LMEFDIV-B7XBFAM";
        pallet-macbook.id = "6JZGMBT-TX43LZJ-L7VCKGI-ZTSAJNV-GFAPC66-ENZ5UDE-SGT2XQV-I3RWFA7";
      };
      folders = {
        keys = {
          id = "5plku-9azor";
          path = "~/Documents/keys";
          devices = [ "phone" "desktop" "server" "pallet-macbook" ];
          inherit ignorePatterns;
        };
        notes = {
          id = "m4rpl-gqmhy";
          path = "~/Documents/notes";
          devices = [ "phone" "desktop" "server" "pallet-macbook" ];
          inherit ignorePatterns;
        };
      };
    };
  };
}
