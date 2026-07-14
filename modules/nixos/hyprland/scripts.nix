{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "gparted" ''
      sudo WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" ${pkgs.gparted}/bin/gparted "$@"
    '')
    (pkgs.writeShellScriptBin "getIdx" ''
      hyprctl activewindow -j | jq -r '. as $win | ($win.grouped | index($win.address)) as $idx | { index: $idx, size: (.grouped | length) }'
    '')

    (pkgs.writeShellScriptBin "shiftTabLeft" ''
      idx=$(getIdx | jq -r .index)
      if [ -z "$idx" ] || [ "$idx" = "null" ]; then
        hyprctl dispatch moveintogroup l 
      elif [ "$idx" -eq 0 ]; then
        hyprctl dispatch moveoutofgroup l 
      else
        hyprctl dispatch movegroupwindow b
      fi
    '')

    (pkgs.writeShellScriptBin "shiftTabRight" ''
      idx=$(getIdx | jq -r .index)
      size=$(getIdx | jq -r .size)

      if [ -z "$idx" ] || [ "$idx" = "null" ]; then
        hyprctl dispatch moveintogroup r
      elif [ "$idx" -eq $((size - 1)) ]; then
        hyprctl dispatch moveoutofgroup r
      else
        hyprctl dispatch movegroupwindow f
      fi
    '')

    (pkgs.writeShellScriptBin "rain-lock" ''
      ${pkgs.swaylock-plugin}/bin/swaylock-plugin \
        --color 000000 \
        --command-each '${pkgs.windowtolayer}/bin/windowtolayer -- ${pkgs.kitty}/bin/kitty -e ${pkgs.terminal-rain-lightning}/bin/terminal-rain'
    '')

  ];
}
