target="${1:?usage: nvim-open <file> [line]}"
line="${2:-}"
line="${line#L}"
line="${line%%[!0-9]*}"

dir="$target"
[ -d "$dir" ] || dir="$(dirname "$target")"
root="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)" || exit 0
if [ -n "${HERDR_WORKSPACE_ID:-}" ]; then
  session="herdr:$HERDR_WORKSPACE_ID"
else
  session="$(tmux list-clients -F '#{client_activity} #{client_session}' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2- || true)"
fi
socket="/tmp/nvim-$(basename "$root")-$(printf %s "$session:$root" | cksum | cut -d' ' -f1).sock"

[ -S "$socket" ] && nvim --server "$socket" --remote-expr 1 >/dev/null 2>&1 || exit 0

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
