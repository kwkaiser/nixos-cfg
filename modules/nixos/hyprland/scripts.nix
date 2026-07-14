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

    (pkgs.writeShellScriptBin "hypr-session-init" ''
      set -u
      exec >>"$HOME/.cache/hypr-session-init.log" 2>&1
      echo "$(date -Is): starting for $HYPRLAND_INSTANCE_SIGNATURE"

      for _ in $(seq 1 100); do
        hyprctl monitors >/dev/null 2>&1 && break
        sleep 0.1
      done

      for _ in $(seq 1 50); do
        hyprctl -j monitors | jq -e '.[] | select(.name == "moonlight")' >/dev/null 2>&1 && break
        hyprctl output create headless moonlight >/dev/null 2>&1
        sleep 0.2
      done
      hyprctl keyword monitor "moonlight,1920x1080@60,5000x0,1"

      systemctl --user start hyprland-session.target
      systemctl --user start hyprpolkitagent
      echo "$(date -Is): done for $HYPRLAND_INSTANCE_SIGNATURE"
    '')

    (pkgs.writeShellScriptBin "hypr-output-bootstrap" ''
      set -u
      exec >>"$HOME/.cache/hypr-output-bootstrap.log" 2>&1
      echo "$(date -Is): watcher starting"
      seen=""
      while true; do
        for sig_dir in "$XDG_RUNTIME_DIR"/hypr/*/; do
          [ -d "$sig_dir" ] || continue
          sig=$(basename "$sig_dir")
          case " $seen " in
            *" $sig "*) continue ;;
          esac
          [ -S "''${sig_dir}.socket.sock" ] || continue
          seen="$seen $sig"
          echo "$(date -Is): found new hyprland instance $sig"
          HYPRLAND_INSTANCE_SIGNATURE="$sig" hypr-session-init &
        done
        sleep 1
      done
    '')

  ];
}
