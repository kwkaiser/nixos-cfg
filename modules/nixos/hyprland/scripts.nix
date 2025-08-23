{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "moonlight" ''
      export WAYLAND_DISPLAY=wayland-1 
      export HYPRLAND_INSTANCE_SIGNATURE=$(cat $XDG_RUNTIME_DIR/hypr/$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -n 1)/hyprland.log | grep "Instance Signature" | cut -d' ' -f 4 | head -n1)
      hyprctl output create headless moonlight
      hyprctl keyword monitor "moonlight,1920x1080,0x0,1"
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

  ];
}
