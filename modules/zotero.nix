{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "zotero" ({ pkgs, ... }: {
  home.packages = with pkgs; [
    zotero
  ];

  home.file.".zotero/zotero/iqnyidkc.default/user.js".text = ''
    user_pref("extensions.zotero.httpServer.localAPI.enabled", true);
  '';
})
