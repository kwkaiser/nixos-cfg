#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: claude-sync <push|pull> <ssh-host> [--dry-run]" >&2
  exit 1
}

[ $# -ge 2 ] || usage
direction="$1"
peer="$2"
shift 2

dry_run=()
for arg in "$@"; do
  case "$arg" in
    --dry-run | -n) dry_run=(--dry-run) ;;
    *) usage ;;
  esac
done

case "$direction" in
  push | pull) ;;
  *) usage ;;
esac

local_home="$HOME"
peer_home="$(ssh -n "$peer" 'echo $HOME')"
[ -n "$peer_home" ] || {
  echo "could not determine \$HOME on $peer" >&2
  exit 1
}

config_dirs=(.claude .claude-personal)

mangle() { printf '%s' "$1" | sed 's#/#-#g'; }

list_script='
cfg="$1"
for d in "$HOME/$cfg/projects"/*/; do
  d="${d%/}"
  name="$(basename "$d")"
  has="$(find "$d" -maxdepth 1 -name "*.jsonl" -print -quit 2>/dev/null)"
  [ -n "$has" ] || continue
  orig=""
  idx="$d/sessions-index.json"
  if [ -f "$idx" ]; then
    orig="$(jq -r ".originalPath // empty" "$idx" 2>/dev/null)"
  fi
  if [ -z "$orig" ]; then
    orig="$(grep -m1 -o "\"cwd\":\"[^\"]*\"" "$has" | sed -E "s/\"cwd\":\"(.*)\"/\1/")"
  fi
  printf "%s\t%s\n" "$name" "$orig"
done
'

sync_dir() {
  echo "==> $1 -> $2"
  rsync -avz --ignore-existing "${dry_run[@]}" "$1/" "$2/"
}

for cfg in "${config_dirs[@]}"; do
  echo "# config: $cfg"
  if [ "$direction" = push ]; then
    while IFS=$'\t' read -r name orig; do
      case "$orig" in
        "$local_home"/*)
          rel="${orig#"$local_home"/}"
          peer_name="$(mangle "$peer_home/$rel")"
          ssh -n "$peer" "mkdir -p ~/$cfg/projects/$peer_name"
          sync_dir "$local_home/$cfg/projects/$name" "$peer:$cfg/projects/$peer_name"
          ;;
        *)
          echo "skip $name (path not under \$HOME: ${orig:-unknown})" >&2
          ;;
      esac
    done < <(bash -c "$list_script" _ "$cfg")
  else
    while IFS=$'\t' read -r name orig; do
      case "$orig" in
        "$peer_home"/*)
          rel="${orig#"$peer_home"/}"
          local_name="$(mangle "$local_home/$rel")"
          mkdir -p "$local_home/$cfg/projects/$local_name"
          sync_dir "$peer:$cfg/projects/$name" "$local_home/$cfg/projects/$local_name"
          ;;
        *)
          echo "skip $name (path not under peer \$HOME: ${orig:-unknown})" >&2
          ;;
      esac
    done < <(ssh "$peer" bash -s -- "$cfg" <<< "$list_script")
  fi
done
