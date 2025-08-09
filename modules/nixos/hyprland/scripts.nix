{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "moveLeft" ''
      idx=$(hyprctl activewindow -j | jq -r '. as $win | ($win.grouped | index($win.address)) as $idx | { index: $idx, size: (.grouped | length) }' | jq -r .index)
      if [ -z "$idx" ] || [ "$idx" = "null" ]; then
        hyprctl dispatch movewindow l
      elif [ "$idx" -eq 0 ]; then
        hyprctl dispatch moveoutofgroup
      else
        hyprctl dispatch movegroupwindow b
      fi
    '')
  ];
}
