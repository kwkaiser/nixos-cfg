{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "timewarrior" (
  { config, lib, pkgs, ... }: {
    home.packages = [ pkgs.timewarrior ];

    home.activation.timewarriorData = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "${config.xdg.dataHome}/timewarrior/data"
    '';

    home.shellAliases.tw = "timew";

    xdg.configFile."timewarrior/timewarrior.cfg".text = ''
      reports.day.hours = auto
      reports.week.hours = auto
      reports.month.hours = auto
      reports.day.totals = on
      reports.week.totals = on
      reports.month.totals = on
      reports.summary.ids = on
      reports.summary.annotations = on
    '';
  }
)
