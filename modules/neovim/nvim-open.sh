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
  local name cwd cmd
  name="$(basename "$root")"
  cwd="$dir"
  while [ "$cwd" != / ] && [ "$(cd "$cwd" 2>/dev/null && pwd -P)" != "$root" ]; do
    cwd="$(dirname "$cwd")"
  done
  [ "$cwd" = / ] && cwd="$root"
  cmd="nvim"
  [ -n "$line" ] && cmd="$cmd +$line"
  cmd="$cmd $(printf %q "$target")"

  if [ -n "${HERDR_WORKSPACE_ID:-}" ]; then
    open_herdr
  elif [ -n "$session" ]; then
    open_tmux
  fi
}

open_herdr() {
  local herdr tab pane shell
  herdr="${HERDR_BIN_PATH:-herdr}"
  tab="$("$herdr" tab list --workspace "$HERDR_WORKSPACE_ID" |
    jq -r --arg n "$name" '[.result.tabs[] | select(.label == $n or (.label | sub("^[0-9]+:"; "")) == $n and (.label | test("^[0-9]+:")))][0].tab_id // empty')"

  if [ -z "$tab" ]; then
    local index
    index="$("$herdr" tab list --workspace "$HERDR_WORKSPACE_ID" |
      jq -r '[.result.tabs[].label | capture("^(?<n>[0-9]+)").n | tonumber] | max // 0 | . + 1')"
    pane="$("$herdr" tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$cwd" --label "$index:$name" --no-focus |
      jq -r '.result.root_pane.pane_id')"
  else
    for shell in $("$herdr" pane list --workspace "$HERDR_WORKSPACE_ID" |
      jq -r --arg t "$tab" '.result.panes[] | select(.tab_id == $t) | .pane_id'); do
      if "$herdr" pane process-info --pane "$shell" |
        jq -e '.result.process_info | (.foreground_processes | length) == 1 and .foreground_processes[0].pid == .shell_pid' >/dev/null; then
        pane="$shell"
        break
      fi
    done
    if [ -z "${pane:-}" ]; then
      pane="$("$herdr" pane list --workspace "$HERDR_WORKSPACE_ID" |
        jq -r --arg t "$tab" '[.result.panes[] | select(.tab_id == $t)][0].pane_id')"
      pane="$("$herdr" pane split "$pane" --direction right --cwd "$cwd" --no-focus | jq -r '.result.pane.pane_id')"
    else
      cmd="cd $(printf %q "$cwd") && $cmd"
    fi
  fi

  "$herdr" pane run "$pane" "$cmd" >/dev/null
  herdr_focus "$pane"
}

herdr_focus() {
  if [ -n "$1" ] && [ -n "${HERDR_SOCKET_PATH:-}" ]; then
    printf '{"id":"nvim-open","method":"pane.focus","params":{"pane_id":"%s"}}\n' "$1" |
      socat -t1 - "UNIX-CONNECT:$HERDR_SOCKET_PATH" >/dev/null
  fi
}

tmux_focus() {
  tmux switch-client -t "$1" 2>/dev/null || true
  tmux select-window -t "$1"
  tmux select-pane -t "$1"
}

open_tmux() {
  local window pane
  window="$(tmux list-windows -t "=$session" -F '#{window_id} #{window_name}' 2>/dev/null |
    awk -v n="$name" '$2 == n { print $1; exit }')"

  if [ -z "$window" ]; then
    pane="$(tmux new-window -d -P -F '#{pane_id}' -t "=$session:" -n "$name" -c "$cwd")"
  else
    pane="$(tmux list-panes -t "$window" -F '#{pane_id} #{pane_current_command}' |
      awk '$2 ~ /^-?zsh$/ { print $1; exit }')"
    if [ -z "$pane" ]; then
      pane="$(tmux split-window -d -h -P -F '#{pane_id}' -t "$window" -c "$cwd")"
    else
      cmd="cd $(printf %q "$cwd") && $cmd"
    fi
  fi

  tmux send-keys -t "$pane" -l "$cmd"
  tmux send-keys -t "$pane" Enter
  tmux_focus "$pane"
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
  herdr_focus "$(nvim --server "$socket" --remote-expr '$HERDR_PANE_ID')"
  exit 0
fi

pane="$(nvim --server "$socket" --remote-expr '$TMUX_PANE')"

if [ -n "$pane" ]; then
  tmux_focus "$pane"
fi
