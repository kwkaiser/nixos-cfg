{lib, ...}: let
  inherit (import ../dendritic-lib.nix {inherit lib;}) mkHmFeature;
in
  mkHmFeature "golang" (
    {
      config,
      pkgs,
      ...
    }: let
      goPath = "${config.home.homeDirectory}/.local/go";
    in {
      programs.go = {
        enable = true;
        env = {
          GOPATH = goPath;
          GOBIN = "${goPath}/bin";
        };
        telemetry.mode = "off";
      };

      home.sessionVariables.GOPATH = goPath;
      home.sessionPath = ["${goPath}/bin"];

      home.packages = with pkgs; [
        gopls
        gotools
        delve
      ];
    }
  )
