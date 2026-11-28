target="${1:?usage: nvim-open <file> [line]}"
line="${2:-}"
line="${line#L}"
line="${line%%[!0-9]*}"

dir="$target"
[ -d "$dir" ] || dir="$(dirname "$target")"
if [ -n "${HERDR_WORKSPACE_ID:-}" ]; then
  session="herdr:$HERDR_WORKSPACE_ID"
else
  session="$(tmux list-clients -F '#{client_activity} #{client_session}' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2- || true)"
fi
{ read -r root && read -r socket; } < <(nvim-socket "$dir" "$session") || exit 0

open_new() {
  local cwd mux target_session args
  command -v tmt >/dev/null || return 0
  if [ -n "${HERDR_WORKSPACE_ID:-}" ]; then
    mux=herdr
    target_session="$HERDR_WORKSPACE_ID"
  elif [ -n "$session" ]; then
    mux=tmux
    target_session="$session"
  else
    return 0
  fi
  cwd="$dir"
  while [ "$cwd" != / ] && [ "$(cd "$cwd" 2>/dev/null && pwd -P)" != "$root" ]; do
    cwd="$(dirname "$cwd")"
  done
  [ "$cwd" = / ] && cwd="$root"
  args=(nvim)
  [ -n "$line" ] && args+=("+$line")
  args+=("$target")
  TMT_MUX="$mux" tmt window -s "$target_session" -C "$cwd" "$(basename "$root")" -- "${args[@]}"
}

if ! { [ -S "$socket" ] && nvim --server "$socket" --remote-expr 1 >/dev/null 2>&1; }; then
  open_new
  exit 0
fi

escaped="${target//\'/\'\'}"
cmds="'drop ' .. fnameescape('$escaped')"
[ -n "$line" ] && cmds="$cmds, '$line', 'normal! zz'"
nvim --server "$socket" --remote-expr "execute([$cmds])" >/dev/null

if [ -n "${HERDR_WORKSPACE_ID:-}" ]; then
  pane="$(nvim --server "$socket" --remote-expr '$HERDR_PANE_ID')"
  if [ -n "$pane" ] && [ -n "${HERDR_SOCKET_PATH:-}" ]; then
    printf '{"id":"nvim-open","method":"pane.focus","params":{"pane_id":"%s"}}\n' "$pane" |
      socat -t1 - "UNIX-CONNECT:$HERDR_SOCKET_PATH" >/dev/null
  fi
  exit 0
fi

pane="$(nvim --server "$socket" --remote-expr '$TMUX_PANE')"

if [ -n "$pane" ]; then
  tmux switch-client -t "$pane" 2>/dev/null || true
  tmux select-window -t "$pane"
  tmux select-pane -t "$pane"
fi
