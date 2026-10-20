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
  tmt new [-B branch] <base> <topic> [repo...]
  tmt add [-t topic] <repo...>
  tmt open [topic]
  tmt ls [-p]
  tmt fresh [base]
  tmt done [-f] [-y] [topic]
  tmt gc
  tmt pick

base is a directory or zoxide query; tasks live under $root/<base name>/<topic>
EOF
}

tabulate() {
  awk -F '\t' '
    {
      rows[NR] = NF
      for (i = 1; i <= NF; i++) {
        cell[NR, i] = $i
        if (length($i) > width[i]) width[i] = length($i)
      }
    }
    END {
      for (r = 1; r <= NR; r++) {
        line = ""
        for (i = 1; i < rows[r]; i++) line = line sprintf("%-" width[i] "s  ", cell[r, i])
        print line cell[r, rows[r]]
      }
    }'
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
    if command -v clonedir >/dev/null && clonedir "$1" "$2" 2>/dev/null; then
      return 0
    fi
    rm -rf "$2"
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
      echo "tmt:   copying $(basename "$src")/$rel"
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

check_repos() {
  local base="$1" r missing=()
  shift
  for r in "$@"; do
    if [ ! -e "$base/$r/.git" ]; then
      missing+=("$r")
    fi
  done
  [ "${#missing[@]}" -eq 0 ] || die "not a git repo under $base: ${missing[*]}"
}

trash_root="$root/.trash"

discard_worktree() {
  local src="$1" wt="$2" force="$3" bin p i=0
  bin="$trash_root/$(date +%s)-$$-$RANDOM"
  mkdir -p "$bin"
  while IFS= read -r p; do
    i=$((i + 1))
    mv "$p" "$bin/$i"
  done < <(find "$wt" -name .git -prune -o -type d -name node_modules -prune -print)
  if [ "$force" -eq 1 ]; then
    git -C "$src" worktree remove --force "$wt"
  else
    git -C "$src" worktree remove "$wt"
  fi
}

empty_trash() {
  local doomed="$trash_root.$$"
  if [ -d "$trash_root" ] && mv "$trash_root" "$doomed"; then
    nohup rm -rf "$doomed" >/dev/null 2>&1 &
  fi
}

rollback_dir=""
created_branches=()

rollback_new() {
  [ -n "$rollback_dir" ] || return 0
  local r entry
  echo "tmt: rolling back $rollback_dir" >&2
  while IFS= read -r r; do
    discard_worktree "$(meta "$rollback_dir" base)/$r" "$rollback_dir/$r" 1 || true
  done < <(worktrees "$rollback_dir")
  empty_trash
  for entry in "${created_branches[@]}"; do
    git -C "${entry%%|*}" branch -D "${entry#*|}" >/dev/null || true
  done
  if [ -z "$(worktrees "$rollback_dir")" ]; then
    rm -rf "$rollback_dir"
    rmdir "$(dirname "$rollback_dir")" 2>/dev/null || true
  fi
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
    created_branches+=("$src|$branch")
  else
    git -C "$src" worktree add --quiet --no-track -b "$branch" "$target" "$start"
    created_branches+=("$src|$branch")
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

resolve_base() {
  local query="$1"
  query="${query/#\~/$HOME}"
  if [ -d "$query" ]; then
    (cd "$query" && pwd)
  else
    zoxide query -- "$query" 2>/dev/null
  fi
}

cmd_new() {
  local branch="" opt
  while getopts "B:" opt; do
    case "$opt" in
      B) branch="$OPTARG" ;;
      *) usage >&2; exit 1 ;;
    esac
  done
  shift $((OPTIND - 1))

  [ "$#" -ge 2 ] || die "usage: tmt new [-B branch] <base> <topic> [repo...]"
  local base topic="$2"
  base="$(resolve_base "$1")" || die "could not resolve '$1' to a directory"
  [[ "$topic" =~ ^[A-Za-z0-9_-]+$ ]] || die "topic must match [A-Za-z0-9_-]+"
  shift 2
  check_repos "$base" "$@"

  local dir
  dir="$root/$(basename "$base")/$topic"
  [ ! -e "$dir" ] || die "$dir already exists"
  mkdir -p "$dir"
  rollback_dir="$dir"
  trap rollback_new EXIT
  trap 'exit 130' INT TERM HUP

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
  rollback_dir=""
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
  check_repos "$(meta "$dir" base)" "$@"
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
  local wt="$1" src="$2" with_pr="${3:-1}" dirty b unpushed own pr=-
  dirty="$(git -C "$wt" status --porcelain | wc -l | tr -d ' ')"
  b="$(git -C "$wt" branch --show-current)"
  own="$(git -C "$wt" rev-list --count "$(start_ref "$src")..HEAD")"
  if git -C "$wt" show-ref --verify --quiet "refs/remotes/origin/$b"; then
    unpushed="$(git -C "$wt" rev-list --count "origin/$b..HEAD")"
  else
    unpushed="$own"
  fi
  if [ "$with_pr" -eq 1 ]; then
    pr="$(cd "$wt" && gh pr view "$b" --json state -q .state 2>/dev/null || echo NONE)"
  fi
  echo "$dirty $unpushed $own $pr $b"
}

is_safe() {
  local dirty="$1" unpushed="$2" pr="$3"
  [ "$dirty" -eq 0 ] || return 1
  [ "$unpushed" -eq 0 ] || [ "$pr" = MERGED ] || [ "$pr" = CLOSED ]
}

cmd_ls() {
  local with_pr=0 opt
  while getopts "p" opt; do
    case "$opt" in
      p) with_pr=1 ;;
      *) usage >&2; exit 1 ;;
    esac
  done

  local tmp dir r i dirs=() repos=()
  tmp="$(mktemp -d)"
  while IFS= read -r dir; do
    if [ -z "$(worktrees "$dir")" ]; then
      dirs+=("$dir")
      repos+=("")
    fi
    while IFS= read -r r; do
      i="${#repos[@]}"
      dirs+=("$dir")
      repos+=("$r")
      repo_status "$dir/$r" "$(meta "$dir" base)/$r" "$with_pr" > "$tmp/$i" &
    done < <(worktrees "$dir")
  done < <(all_tasks)
  wait

  local task base session prev="" dirty unpushed own pr b
  {
    printf 'TASK\tBASE\tSESSION\tREPO\tBRANCH\tDIRTY\tCOMMITS\tUNPUSHED'
    [ "$with_pr" -eq 0 ] || printf '\tPR'
    printf '\n'
    for i in "${!dirs[@]}"; do
      dir="${dirs[$i]}"
      r="${repos[$i]}"
      task=""
      base=""
      session=""
      if [ "$dir" != "$prev" ]; then
        task="$(meta "$dir" topic)"
        base="$(basename "$(meta "$dir" base)")"
        session=up
        tmux has-session -t "=$(meta "$dir" session)" 2>/dev/null || session=down
        prev="$dir"
      fi
      if [ -z "$r" ]; then
        printf '%s\t%s\t%s\t-\t-\t-\t-\t-' "$task" "$base" "$session"
        pr=-
      else
        read -r dirty unpushed own pr b < "$tmp/$i"
        printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s' "$task" "$base" "$session" "$r" "$b" "$dirty" "$own" "$unpushed"
      fi
      [ "$with_pr" -eq 0 ] || printf '\t%s' "$pr"
      printf '\n'
    done
  } | tabulate
  rm -rf "$tmp"
}

remove_task() {
  local dir="$1" force="$2" assume_yes="$3"
  local base session topic r dirty unpushed own pr b blocked=0
  local -A status_of=()
  base="$(meta "$dir" base)"
  session="$(meta "$dir" session)"
  topic="$(meta "$dir" topic)"

  while IFS= read -r r; do
    status_of[$r]="$(repo_status "$dir/$r" "$base/$r")"
    read -r dirty unpushed own pr b <<< "${status_of[$r]}"
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
    read -r dirty unpushed own pr b <<< "${status_of[$r]}"
    discard_worktree "$base/$r" "$dir/$r" "$force"
    if [ "$own" -eq 0 ] || [ "$pr" = MERGED ] || [ "$pr" = CLOSED ]; then
      git -C "$base/$r" branch -D "$b" >/dev/null
      echo "tmt: removed $r worktree and branch $b"
    else
      echo "tmt: removed $r worktree, kept branch $b"
    fi
  done < <(worktrees "$dir")

  empty_trash
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
  for dir in "${candidates[@]}"; do
    printf '  %s\t%s\t%s\n' "$(meta "$dir" topic)" "$(basename "$(meta "$dir" base)")" "$(worktrees "$dir" | tr '\n' ' ')"
  done | tabulate
  local reply
  read -r -p "Remove all of these? [y/N] " reply
  [ "$reply" = y ] || [ "$reply" = Y ] || die "aborted"
  for dir in "${candidates[@]}"; do
    remove_task "$dir" 0 1
  done
}

paint() {
  printf '\033[%sm%s\033[0m' "$1" "$2"
}

fzf_pick() {
  local label="$1" preview="$2"
  shift 2
  fzf --ansi --layout=reverse --info=inline-right --highlight-line \
    --border=rounded --border-label=" $label " --padding=0,1 \
    --prompt='❯ ' --pointer='▌' --gutter=' ' --marker='▍' --separator='─' --scrollbar='│' \
    --color="$fzf_colors" \
    --delimiter='\t' --with-nth=2.. \
    --preview="$preview" --preview-window='right,55%,border-left,<60(down,50%,border-top)' \
    "$@"
}

cmd_preview() {
  local kind="$1" dir="$2" name="$3" r
  case "$kind" in
    task)
      paint "$sgr_accent" "$(meta "$dir" topic)"
      printf '  %s\n\n' "$(paint "$sgr_dim" "$(meta "$dir" base)")"
      while IFS= read -r r; do
        printf '%s %s\n' "$(paint "$sgr_worktree" "")" "$r"
        git -C "$dir/$r" -c color.status=always status -sb | sed 's/^/  /'
        echo
      done < <(worktrees "$dir")
      ;;
    root)
      cat "$dir/CLAUDE.md"
      ;;
    repo)
      git -C "$dir/$name" -c color.status=always status -sb
      echo
      git -C "$dir/$name" log --color=always --graph --oneline --decorate -n 40
      ;;
  esac
}

pick_task() {
  local choice d session w=0 t
  while IFS= read -r d; do
    t="$(meta "$d" topic)"
    [ "${#t}" -le "$w" ] || w="${#t}"
  done < <(all_tasks)
  choice="$(
    while IFS= read -r d; do
      printf "%s\t%s %-${w}s  %s\n" "$d" "$(paint "$sgr_root" "")" "$(meta "$d" topic)" \
        "$(paint "$sgr_dim" "$(basename "$(meta "$d" base)")")"
    done < <(all_tasks) |
      fzf_pick "Tasks" "$0 _preview task {1} ''" \
        --header=":: $(paint "$sgr_accent" "<enter>") open task"
  )" || return 0
  d="${choice%%$'\t'*}"
  session="$(ensure_session "$d")"
  attach "$session"
}

cmd_pick() {
  local dir
  if ! dir="$(current_task)"; then
    pick_task
    return 0
  fi

  local session out key repo e name id w=6
  session="$(meta "$dir" session)"
  for e in "$dir"/*; do
    name="$(basename "$e")"
    [ "${#name}" -le "$w" ] || w="${#name}"
  done
  out="$(
    {
      printf "claude\t%s %-${w}s  %s\n" "$(paint "$sgr_root" "")" claude "$(paint "$sgr_dim" "task root")"
      for e in "$dir"/*; do
        name="$(basename "$e")"
        if [ -L "$e" ]; then
          printf "%s\t%s %-${w}s  %s\n" "$name" "$(paint "$sgr_main" "")" "$name" "$(paint "$sgr_dim" "main checkout")"
        elif [ -d "$e" ]; then
          printf "%s\t%s %-${w}s  %s\n" "$name" "$(paint "$sgr_worktree" "")" "$name" \
            "$(paint "$sgr_worktree" "$(git -C "$e" branch --show-current)")"
        fi
      done
    } | fzf_pick "$(meta "$dir" topic)" "$0 _preview \"\$([ {1} = claude ] && echo root || echo repo)\" $(printf '%q' "$dir") {1}" \
      --expect=ctrl-a \
      --header=":: $(paint "$sgr_accent" "<enter>") jump  $(paint "$sgr_accent" "<ctrl-a>") make worktree"
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

fresh_repo() {
  local src="$1" name def where before after n
  name="$(basename "$src")"
  if ! git -C "$src" fetch --quiet --prune origin 2>/dev/null; then
    printf '%s\t-\tfetch failed\n' "$name"
    return 0
  fi
  def="$(start_ref "$src")"
  if [ "$def" = HEAD ]; then
    printf '%s\t-\tfetched, no origin default branch\n' "$name"
    return 0
  fi
  def="${def#origin/}"
  if ! git -C "$src" show-ref --verify --quiet "refs/heads/$def"; then
    printf '%s\t%s\tfetched, no local branch\n' "$name" "$def"
    return 0
  fi

  before="$(git -C "$src" rev-parse "$def")"
  where="$(git -C "$src" worktree list --porcelain |
    awk -v b="branch refs/heads/$def" '/^worktree / { w = substr($0, 10) } $0 == b { print w }')"
  if [ -z "$where" ]; then
    if ! git -C "$src" fetch --quiet . "origin/$def:$def" 2>/dev/null; then
      printf '%s\t%s\tskipped: diverged from origin/%s\n' "$name" "$def" "$def"
      return 0
    fi
  elif [ -n "$(git -C "$where" status --porcelain --untracked-files=no)" ]; then
    printf '%s\t%s\tskipped: checked out with uncommitted changes\n' "$name" "$def"
    return 0
  elif ! git -C "$where" merge --quiet --ff-only "origin/$def" >/dev/null 2>&1; then
    printf '%s\t%s\tskipped: diverged from origin/%s\n' "$name" "$def" "$def"
    return 0
  fi
  after="$(git -C "$src" rev-parse "$def")"

  n="$(git -C "$src" rev-list --count "$before..$after")"
  case "$n" in
    0) printf '%s\t%s\tup to date\n' "$name" "$def" ;;
    1) printf '%s\t%s\t+1 commit\n' "$name" "$def" ;;
    *) printf '%s\t%s\t+%s commits\n' "$name" "$def" "$n" ;;
  esac
}

cmd_fresh() {
  local base dir r out
  if [ -n "${1:-}" ]; then
    base="$(resolve_base "$1")" || die "could not resolve '$1' to a directory"
  elif dir="$(current_task)"; then
    base="$(meta "$dir" base)"
  else
    die "usage: tmt fresh [base]"
  fi

  out="$(mktemp -d)"
  for r in "$base"/*/; do
    r="${r%/}"
    if [ -e "$r/.git" ]; then
      fresh_repo "$r" > "$out/$(basename "$r")" 2>&1 &
    fi
  done
  wait
  cat "$out"/* | tabulate
  rm -rf "$out"
}

cmd_complete() {
  local base dir r e
  case "${1:-}" in
    tasks)
      while IFS= read -r dir; do
        meta "$dir" topic
      done < <(all_tasks)
      ;;
    base-repos)
      base="$(resolve_base "${2:-}")" || return 0
      for r in "$base"/*/; do
        r="${r%/}"
        if [ -e "$r/.git" ]; then
          basename "$r"
        fi
      done
      ;;
    task-repos)
      dir="$(resolve_task "${2:-}")"
      for e in "$dir"/*; do
        if [ -L "$e" ]; then
          basename "$e"
        fi
      done
      ;;
  esac
}

cmd="${1:-}"
if [ "$#" -gt 0 ]; then
  shift
fi
case "$cmd" in
  new) cmd_new "$@" ;;
  add) cmd_add "$@" ;;
  open) cmd_open "$@" ;;
  ls) cmd_ls "$@" ;;
  fresh) cmd_fresh "$@" ;;
  done) cmd_done "$@" ;;
  gc) cmd_gc ;;
  pick) cmd_pick ;;
  _preview) cmd_preview "$@" ;;
  _complete) cmd_complete "$@" ;;
  -h | --help | help) usage ;;
  *) usage >&2; exit 1 ;;
esac
