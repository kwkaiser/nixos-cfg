target="${1:?usage: nvim-open <file> [line]}"
line="${2:-}"
line="${line#L}"
line="${line%%[!0-9]*}"

dir="$target"
[ -d "$dir" ] || dir="$(dirname "$target")"
root="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)" || exit 0
socket="/tmp/nvim-$(basename "$root")-$(printf %s "$root" | cksum | cut -d' ' -f1).sock"

[ -S "$socket" ] && nvim --server "$socket" --remote-expr 1 >/dev/null 2>&1 || exit 0

escaped="${target//\'/\'\'}"
cmds="'drop ' .. fnameescape('$escaped')"
[ -n "$line" ] && cmds="$cmds, '$line', 'normal! zz'"
nvim --server "$socket" --remote-expr "execute([$cmds])" >/dev/null
pane="$(nvim --server "$socket" --remote-expr '$TMUX_PANE')"

if [ -n "$pane" ]; then
  tmux switch-client -t "$pane" 2>/dev/null || true
  tmux select-window -t "$pane"
  tmux select-pane -t "$pane"
fi
