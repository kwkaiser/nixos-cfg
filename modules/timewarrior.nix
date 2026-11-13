{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "timewarrior" (
  { config, lib, pkgs, ... }:
  let
    c = lib.mapAttrs (_: v: "0x${v}") config.lib.stylix.colors;
    tagColors = [ c.base08 c.base09 c.base0A c.base0B c.base0C c.base0D c.base0E c.base0F ];
    palette = lib.concatImapStringsSep "\n" (
      i: bg: ''theme.palette.color${lib.fixedWidthNumber 2 i} = ${c.base00} on ${bg}''
    ) tagColors;
  in
  {
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

      theme.description = stylix base16
      theme.colors.label = ${c.base04}
      theme.colors.today = ${c.base0A}
      theme.colors.holiday = ${c.base03}
      theme.colors.exclusion = ${c.base04} on ${c.base01}
      theme.colors.ids = ${c.base0E}
      theme.colors.debug = ${c.base0D}
      ${palette}
    '';
  }
)
