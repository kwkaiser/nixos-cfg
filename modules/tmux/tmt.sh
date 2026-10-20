root="${TMT_ROOT:-$HOME/tasks}"
branch_prefix="${TMT_BRANCH_PREFIX:-u/kwkaiser/}"
read -r -a clone_names <<< "${TMT_CLONE:-node_modules .env .env.local .env.mcp}"

die() {
  echo "tmt: $*" >&2
  exit 1
}

usage() {
  cat <<EOF
usage:
  tmt new [-b base] [-B branch] <topic> [repo...]
  tmt add [-t topic] <repo...>
  tmt open [topic]
  tmt ls
  tmt done [-f] [-y] [topic]
  tmt gc
  tmt pick

base defaults to \$TMT_BASE; tasks live under $root/<base name>/<topic>
EOF
}

meta() {
  sed -n "s/^$2=//p" "$1/.tmt"
}

all_tasks() {
  local f
  for f in "$root"/*/*/.tmt; do
    if [ -f "$f" ]; then
      dirname "$f"
    fi
  done
}

current_task() {
  local d=""
  if [ -n "${TMUX:-}" ]; then
    d="$(tmux display -p '#{@tmt_task}' 2>/dev/null || true)"
  fi
  if [ -n "$d" ] && [ -f "$d/.tmt" ]; then
    echo "$d"
    return 0
  fi
  d="$PWD"
  while [ "$d" != / ]; do
    if [ -f "$d/.tmt" ]; then
      echo "$d"
      return 0
    fi
    d="$(dirname "$d")"
  done
  return 1
}

resolve_task() {
  if [ -z "${1:-}" ]; then
    current_task || die "not inside a task; pass a topic"
    return 0
  fi
  local matches=() d
  while IFS= read -r d; do
    if [ "$(basename "$d")" = "$1" ]; then
      matches+=("$d")
    fi
  done < <(all_tasks)
  [ "${#matches[@]}" -eq 1 ] || die "expected exactly one task named '$1', found ${#matches[@]}"
  echo "${matches[0]}"
}

worktrees() {
  local e
  for e in "$1"/*; do
    if [ -d "$e" ] && [ ! -L "$e" ]; then
      basename "$e"
    fi
  done
}

start_ref() {
  local ref
  for ref in origin/HEAD origin/main origin/master; do
    if git -C "$1" rev-parse --verify --quiet "$ref" >/dev/null; then
      git -C "$1" rev-parse --abbrev-ref "$ref"
      return 0
    fi
  done
  echo HEAD
}

clone_path() {
  mkdir -p "$(dirname "$2")"
  if [ "$(uname)" = Darwin ]; then
    /bin/cp -cR "$1" "$2"
  else
    cp -R --reflink=auto "$1" "$2"
  fi
}

clone_untracked() {
  local src="$1" dst="$2" args=() n p rel
  for n in "${clone_names[@]}"; do
    if [ "${#args[@]}" -gt 0 ]; then
      args+=(-o)
    fi
    args+=(-name "$n")
  done
  while IFS= read -r p; do
    rel="${p#"$src"/}"
    if [ ! -e "$dst/$rel" ]; then
      clone_path "$p" "$dst/$rel"
    fi
  done < <(find "$src" -name .git -prune -o \( "${args[@]}" \) -prune -print)
}

write_claude_md() {
  local dir="$1" topic r
  topic="$(meta "$dir" topic)"
  {
    echo "# Task: $topic"
    echo
    echo "This directory mirrors $(meta "$dir" base)."
    echo "These repos are git worktrees on branch \`$(meta "$dir" branch)\` and are the only ones you may modify:"
    echo
    while IFS= read -r r; do
      echo "- $r"
    done < <(worktrees "$dir")
    echo
    echo "Every other directory is a symlink to the shared main checkout and is read-only."
    echo "To modify one, first run \`tmt add -t $topic <repo>\`, which converts it into a worktree for this task."
  } > "$dir/CLAUDE.md"
}

window_id() {
  tmux list-windows -t "=$1" -F '#{window_id} #{window_name}' 2>/dev/null |
    awk -v n="$2" '$2 == n { print $1; exit }'
}

add_repo() {
  local dir="$1" repo="$2"
  local base branch session src target start
  base="$(meta "$dir" base)"
  branch="$(meta "$dir" branch)"
  session="$(meta "$dir" session)"
  src="$base/$repo"
  target="$dir/$repo"

  [ -e "$src/.git" ] || die "$src is not a git repo"
  if [ -d "$target" ] && [ ! -L "$target" ]; then
    echo "tmt: $repo is already a worktree"
    return 0
  fi
  rm -f "$target"

  git -C "$src" fetch --quiet origin || echo "tmt: fetch failed for $repo, using local refs" >&2
  start="$(start_ref "$src")"

  if git -C "$src" show-ref --verify --quiet "refs/heads/$branch"; then
    git -C "$src" worktree add --quiet "$target" "$branch"
  elif git -C "$src" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    git -C "$src" worktree add --quiet --track -b "$branch" "$target" "origin/$branch"
  else
    git -C "$src" worktree add --quiet --no-track -b "$branch" "$target" "$start"
  fi

  clone_untracked "$src" "$target"

  if tmux has-session -t "=$session" 2>/dev/null && [ -z "$(window_id "$session" "$repo")" ]; then
    tmux new-window -d -t "=$session:" -n "$repo" -c "$target"
  fi
  echo "tmt: $repo -> $target ($branch from $start)"
}

ensure_session() {
  local dir="$1" session pane r
  session="$(meta "$dir" session)"
  if ! tmux has-session -t "=$session" 2>/dev/null; then
    pane="$(tmux new-session -d -P -F '#{pane_id}' -s "$session" -n claude -c "$dir")"
    tmux set-option -t "$pane" @tmt_task "$dir"
    tmux send-keys -t "$pane" "clear && ccp" Enter
    while IFS= read -r r; do
      tmux new-window -d -t "=$session:" -n "$r" -c "$dir/$r"
    done < <(worktrees "$dir")
  elif [ "$(tmux show-options -t "=$session:" -v @tmt_task 2>/dev/null)" != "$dir" ]; then
    die "tmux session '$session' exists but does not belong to this task"
  fi
  echo "$session"
}

attach() {
  if [ -n "${TMUX:-}" ]; then
    tmux switch-client -t "=$1"
  else
    tmux attach-session -t "=$1"
  fi
}

cmd_new() {
  local base="${TMT_BASE:-}" branch="" opt
  while getopts "b:B:" opt; do
    case "$opt" in
      b) base="$OPTARG" ;;
      B) branch="$OPTARG" ;;
      *) usage >&2; exit 1 ;;
    esac
  done
  shift $((OPTIND - 1))

  local topic="${1:-}"
  [ -n "$topic" ] || die "usage: tmt new [-b base] [-B branch] <topic> [repo...]"
  [[ "$topic" =~ ^[A-Za-z0-9_-]+$ ]] || die "topic must match [A-Za-z0-9_-]+"
  shift
  [ -n "$base" ] || die "no base directory; set TMT_BASE or pass -b"
  base="${base/#\~/$HOME}"
  [ -d "$base" ] || die "$base is not a directory"
  base="$(cd "$base" && pwd)"

  local dir
  dir="$root/$(basename "$base")/$topic"
  [ ! -e "$dir" ] || die "$dir already exists"
  mkdir -p "$dir"

  {
    echo "topic=$topic"
    echo "base=$base"
    echo "branch=${branch:-$branch_prefix$topic-1}"
    echo "session=$topic"
  } > "$dir/.tmt"

  local r
  for r in "$base"/*/; do
    r="${r%/}"
    if [ -e "$r/.git" ]; then
      ln -s "$r" "$dir/$(basename "$r")"
    fi
  done

  for r in "$@"; do
    add_repo "$dir" "$r"
  done
  write_claude_md "$dir"
  local session
  session="$(ensure_session "$dir")"
  attach "$session"
}

cmd_add() {
  local topic="" opt
  while getopts "t:" opt; do
    case "$opt" in
      t) topic="$OPTARG" ;;
      *) usage >&2; exit 1 ;;
    esac
  done
  shift $((OPTIND - 1))
  [ "$#" -gt 0 ] || die "usage: tmt add [-t topic] <repo...>"

  local dir r
  dir="$(resolve_task "$topic")"
  for r in "$@"; do
    add_repo "$dir" "$r"
  done
  write_claude_md "$dir"
}

cmd_open() {
  local dir session
  dir="$(resolve_task "${1:-}")"
  session="$(ensure_session "$dir")"
  attach "$session"
}

repo_status() {
  local wt="$1" src="$2" dirty b unpushed own pr
  dirty="$(git -C "$wt" status --porcelain | wc -l | tr -d ' ')"
  b="$(git -C "$wt" branch --show-current)"
  own="$(git -C "$wt" rev-list --count "$(start_ref "$src")..HEAD")"
  if git -C "$wt" show-ref --verify --quiet "refs/remotes/origin/$b"; then
    unpushed="$(git -C "$wt" rev-list --count "origin/$b..HEAD")"
  else
    unpushed="$own"
  fi
  pr="$(cd "$wt" && gh pr view "$b" --json state -q .state 2>/dev/null || echo NONE)"
  echo "$dirty $unpushed $own $pr $b"
}

is_safe() {
  local dirty="$1" unpushed="$2" pr="$3"
  [ "$dirty" -eq 0 ] || return 1
  [ "$unpushed" -eq 0 ] || [ "$pr" = MERGED ] || [ "$pr" = CLOSED ]
}

cmd_ls() {
  local dir state r dirty unpushed own pr b
  while IFS= read -r dir; do
    state="session up"
    tmux has-session -t "=$(meta "$dir" session)" 2>/dev/null || state="no session"
    printf '%s  (%s, %s)\n' "$(meta "$dir" topic)" "$(basename "$(meta "$dir" base)")" "$state"
    while IFS= read -r r; do
      read -r dirty unpushed own pr b < <(repo_status "$dir/$r" "$(meta "$dir" base)/$r")
      printf '  %-24s %-40s dirty:%-3s commits:%-3s unpushed:%-3s pr:%s\n' "$r" "$b" "$dirty" "$own" "$unpushed" "$pr"
    done < <(worktrees "$dir")
  done < <(all_tasks)
}

remove_task() {
  local dir="$1" force="$2" assume_yes="$3"
  local base session topic r dirty unpushed own pr b blocked=0
  base="$(meta "$dir" base)"
  session="$(meta "$dir" session)"
  topic="$(meta "$dir" topic)"

  while IFS= read -r r; do
    read -r dirty unpushed own pr b < <(repo_status "$dir/$r" "$base/$r")
    if ! is_safe "$dirty" "$unpushed" "$pr"; then
      echo "tmt: $r has dirty:$dirty unpushed:$unpushed pr:$pr" >&2
      blocked=1
    fi
  done < <(worktrees "$dir")
  if [ "$blocked" -eq 1 ] && [ "$force" -eq 0 ]; then
    die "refusing to remove $topic; pass -f to force"
  fi

  if [ "$assume_yes" -eq 0 ]; then
    local reply
    read -r -p "Remove task $topic ($(worktrees "$dir" | tr '\n' ' '))? [y/N] " reply
    [ "$reply" = y ] || [ "$reply" = Y ] || die "aborted"
  fi

  while IFS= read -r r; do
    read -r dirty unpushed own pr b < <(repo_status "$dir/$r" "$base/$r")
    if [ "$force" -eq 1 ]; then
      git -C "$base/$r" worktree remove --force "$dir/$r"
    else
      git -C "$base/$r" worktree remove "$dir/$r"
    fi
    if [ "$own" -eq 0 ] || [ "$pr" = MERGED ] || [ "$pr" = CLOSED ]; then
      git -C "$base/$r" branch -D "$b" >/dev/null
      echo "tmt: removed $r worktree and branch $b"
    else
      echo "tmt: removed $r worktree, kept branch $b"
    fi
  done < <(worktrees "$dir")

  [ -z "$(worktrees "$dir")" ] || die "worktrees remain in $dir, not deleting it"
  rm -rf "$dir"
  rmdir "$(dirname "$dir")" 2>/dev/null || true
  tmux kill-session -t "=$session" 2>/dev/null || true
}

cmd_done() {
  local force=0 assume_yes=0 opt dir
  while getopts "fy" opt; do
    case "$opt" in
      f) force=1 ;;
      y) assume_yes=1 ;;
      *) usage >&2; exit 1 ;;
    esac
  done
  shift $((OPTIND - 1))
  dir="$(resolve_task "${1:-}")"
  remove_task "$dir" "$force" "$assume_yes"
}

cmd_gc() {
  local dir r dirty unpushed own pr b ok n candidates=()
  while IFS= read -r dir; do
    ok=1
    n=0
    while IFS= read -r r; do
      n=$((n + 1))
      read -r dirty unpushed own pr b < <(repo_status "$dir/$r" "$(meta "$dir" base)/$r")
      if [ "$dirty" -ne 0 ] || { [ "$pr" != MERGED ] && [ "$pr" != CLOSED ]; }; then
        ok=0
      fi
    done < <(worktrees "$dir")
    if [ "$ok" -eq 1 ] && [ "$n" -gt 0 ]; then
      candidates+=("$dir")
    fi
  done < <(all_tasks)

  if [ "${#candidates[@]}" -eq 0 ]; then
    echo "tmt: nothing to clean up"
    return 0
  fi
  echo "tasks whose PRs are all merged or closed:"
  printf '  %s\n' "${candidates[@]}"
  local reply
  read -r -p "Remove all of these? [y/N] " reply
  [ "$reply" = y ] || [ "$reply" = Y ] || die "aborted"
  for dir in "${candidates[@]}"; do
    remove_task "$dir" 0 1
  done
}

pick_task() {
  local choice d session
  choice="$(
    while IFS= read -r d; do
      printf '%s\t%s\n' "$(meta "$d" topic)" "$(basename "$(meta "$d" base)")"
    done < <(all_tasks) | fzf --delimiter='\t' --prompt='task> '
  )" || return 0
  d="$(resolve_task "${choice%%$'\t'*}")"
  session="$(ensure_session "$d")"
  attach "$session"
}

cmd_pick() {
  local dir
  if ! dir="$(current_task)"; then
    pick_task
    return 0
  fi

  local session out key repo e id
  session="$(meta "$dir" session)"
  out="$(
    {
      printf 'claude\t(task root)\n'
      for e in "$dir"/*; do
        if [ -L "$e" ]; then
          printf '%s\t(main checkout)\n' "$(basename "$e")"
        elif [ -d "$e" ]; then
          printf '%s\t%s\n' "$(basename "$e")" "$(git -C "$e" branch --show-current)"
        fi
      done
    } | fzf --expect=ctrl-a --delimiter='\t' --prompt="$(meta "$dir" topic)> " \
      --header='enter: jump   ctrl-a: make worktree'
  )" || return 0

  key="$(sed -n 1p <<< "$out")"
  repo="$(sed -n 2p <<< "$out")"
  repo="${repo%%$'\t'*}"
  [ -n "$repo" ] || return 0

  if [ "$key" = ctrl-a ] && [ "$repo" != claude ]; then
    add_repo "$dir" "$repo"
    write_claude_md "$dir"
  fi

  id="$(window_id "$session" "$repo")"
  if [ -z "$id" ]; then
    id="$(tmux new-window -d -P -F '#{window_id}' -t "=$session:" -n "$repo" -c "$dir/$repo")"
  fi
  tmux select-window -t "$id"
}

cmd="${1:-}"
if [ "$#" -gt 0 ]; then
  shift
fi
case "$cmd" in
  new) cmd_new "$@" ;;
  add) cmd_add "$@" ;;
  open) cmd_open "$@" ;;
  ls) cmd_ls ;;
  done) cmd_done "$@" ;;
  gc) cmd_gc ;;
  pick) cmd_pick ;;
  -h | --help | help) usage ;;
  *) usage >&2; exit 1 ;;
esac
