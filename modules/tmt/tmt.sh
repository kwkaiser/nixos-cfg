root="${TMT_ROOT:-$HOME/tasks}"
branch_prefix="${TMT_BRANCH_PREFIX:-u/kwkaiser/}"
read -r -a clone_names <<< "${TMT_CLONE:-node_modules .env .env.local .env.mcp}"

if [ -n "${TMT_MUX:-}" ]; then
  mux="$TMT_MUX"
elif [ "${HERDR_ENV:-}" = 1 ]; then
  mux=herdr
else
  mux=tmux
fi
herdr_bin="${HERDR_BIN_PATH:-herdr}"

die() {
  echo "tmt: $*" >&2
  exit 1
}

usage() {
  cat <<EOF
usage:
  tmt create
  tmt new [-B branch] <base> <topic> [repo...]
  tmt add [-t topic] <repo...>
  tmt open [topic]
  tmt ls [-p]
  tmt fresh [base]
  tmt done [-f] [-y] [topic]
  tmt close
  tmt gc
  tmt pick
  tmt switch

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

session_task() {
  local d
  [ -n "$1" ] || return 1
  while IFS= read -r d; do
    if [ "$(meta "$d" session)" = "$1" ]; then
      echo "$d"
      return 0
    fi
  done < <(all_tasks)
  return 1
}

current_task() {
  local d
  if session_task "$(mux_current_session)"; then
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

is_github() {
  case "$(git -C "$1" remote get-url origin 2>/dev/null)" in
    *github.com[:/]*) return 0 ;;
  esac
  return 1
}

gitea_pulls() {
  local dir="$1" state="$2" filter="$3" page out res
  for page in 1 2 3 4; do
    out="$(cd "$dir" && tea api "repos/{owner}/{repo}/pulls?state=$state&limit=50&page=$page" 2>/dev/null)" || return 0
    jq -e 'type == "array" and length > 0' <<< "$out" >/dev/null 2>&1 || return 0
    res="$(jq -r "$filter" <<< "$out")"
    [ -z "$res" ] || echo "$res"
  done
}

pr_cache=""

pr_file() {
  echo "$pr_cache/$(printf '%s' "$1" | tr -c 'A-Za-z0-9' _)"
}

github_prs() {
  local src="$1" i=0 b state q="" decl="" vars=() branches
  shift
  branches=("$@")
  for b in "$@"; do
    q+="b$i:pullRequests(headRefName:\$h$i,first:1,orderBy:{field:CREATED_AT,direction:DESC}){nodes{state}} "
    decl+=",\$h$i:String!"
    vars+=(-f "h$i=$b")
    i=$((i + 1))
  done
  (cd "$src" && gh api graphql -F owner='{owner}' -F repo='{repo}' "${vars[@]}" \
    -f query="query(\$owner:String!,\$repo:String!$decl){repository(owner:\$owner,name:\$repo){$q}}" \
    -q '.data.repository | to_entries[] | "\(.key | ltrimstr("b"))\t\(.value.nodes[0].state // "NONE")"' 2>/dev/null) |
    while IFS=$'\t' read -r i state; do
      printf '%s\t%s\n' "${branches[$i]}" "$state"
    done
}

fetch_prs() {
  local src="$1" f
  shift
  f="$(pr_file "$src")"
  if ! is_github "$src"; then
    gitea_pulls "$src" all \
      '.[] | "\(.head.label)\t\(if .merged then "MERGED" elif .state == "closed" then "CLOSED" else "OPEN" end)\t\(.head.sha)"' > "$f.tmp"
  elif [ "$#" -gt 0 ]; then
    github_prs "$src" "$@" > "$f.tmp" || true
  else
    : > "$f.tmp"
  fi
  mv "$f.tmp" "$f"
}

prefetch_prs() {
  local src pids=() branches=()
  [ "$#" -gt 0 ] || return 0
  if [ -z "$pr_cache" ]; then
    pr_cache="$(mktemp -d)"
    trap 'rm -rf "$pr_cache"' EXIT
  fi
  while IFS= read -r src; do
    if [ -n "$src" ] && [ ! -f "$(pr_file "$src")" ]; then
      mapfile -t branches < <(printf '%s\n' "$@" | awk -F '\t' -v s="$src" '$1 == s && $2 != "" { print $2 }' | sort -u)
      fetch_prs "$src" "${branches[@]}" &
      pids+=("$!")
    fi
  done < <(printf '%s\n' "$@" | cut -f1 | sort -u)
  [ "${#pids[@]}" -eq 0 ] || wait "${pids[@]}"
}

pr_state() {
  local src="$1" b="$2" state
  if [ -z "$pr_cache" ] || [ ! -f "$(pr_file "$src")" ]; then
    prefetch_prs "$src"$'\t'"$b"
  fi
  state="$(awk -F '\t' -v b="$b" '$1 == b { print $2; exit }' "$(pr_file "$src")")"
  echo "${state:-NONE}"
}

task_branches() {
  local dir r
  while IFS= read -r dir; do
    while IFS= read -r r; do
      printf '%s\t%s\n' "$(meta "$dir" base)/$r" "$(git -C "$dir/$r" branch --show-current)"
    done < <(worktrees "$dir")
  done < <(all_tasks) | sort -u
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

write_mcp_json() {
  local dir="$1" f configs=()
  for f in "$dir"/*/.mcp.json; do
    if [ -f "$f" ]; then
      configs+=("$f")
    fi
  done
  if [ "${#configs[@]}" -eq 0 ]; then
    rm -f "$dir/.mcp.json"
    return 0
  fi
  jq -s 'map(.mcpServers // {}) | add | {mcpServers: .}' "${configs[@]}" > "$dir/.mcp.json"
}

herdr_workspace_id() {
  "$herdr_bin" workspace list |
    jq -r --arg l "$1" '[.result.workspaces[] | select(.label == $l)][0].workspace_id // empty'
}

mux_current_session() {
  case "$mux" in
    tmux)
      if [ -n "${TMUX:-}" ]; then
        tmux display -p '#S' 2>/dev/null || true
      fi
      ;;
    herdr)
      if [ "${HERDR_ENV:-}" = 1 ]; then
        "$herdr_bin" workspace list | jq -r '[.result.workspaces[] | select(.focused)][0].label // empty'
      fi
      ;;
  esac
}

mux_has_session() {
  case "$mux" in
    tmux) tmux has-session -t "=$1" 2>/dev/null ;;
    herdr) [ -n "$(herdr_workspace_id "$1")" ] ;;
  esac
}

window_id() {
  local ws
  case "$mux" in
    tmux)
      tmux list-windows -t "=$1" -F '#{window_id} #{window_name}' 2>/dev/null |
        awk -v n="$2" '$2 == n { print $1; exit }'
      ;;
    herdr)
      ws="$(herdr_workspace_id "$1")"
      [ -n "$ws" ] || return 0
      "$herdr_bin" tab list --workspace "$ws" |
        jq -r --arg n "$2" '[.result.tabs[] | select(.label == $n or ((.label | test("^[0-9]+:")) and ((.label | sub("^[0-9]+:"; "")) == $n)))][0].tab_id // empty'
      ;;
  esac
}

mux_new_window() {
  local session="$1" name="$2" cwd="$3" ws next
  case "$mux" in
    tmux)
      tmux new-window -d -P -F '#{window_id}' -t "=$session:" -n "$name" -c "$cwd"
      ;;
    herdr)
      ws="$(herdr_workspace_id "$session")"
      next="$("$herdr_bin" tab list --workspace "$ws" |
        jq -r '[.result.tabs[].label | capture("^(?<n>[0-9]+)") | .n | tonumber] | (max // 0) + 1')"
      "$herdr_bin" tab create --workspace "$ws" --cwd "$cwd" --label "$next:$name" --no-focus |
        jq -r .result.tab.tab_id
      if command -v herdr-sort-tabs >/dev/null; then
        herdr-sort-tabs "$ws"
      fi
      ;;
  esac
}

mux_kill_window() {
  case "$mux" in
    tmux) tmux kill-window -t "$1" ;;
    herdr) "$herdr_bin" tab close "$1" >/dev/null ;;
  esac
}

mux_select_window() {
  case "$mux" in
    tmux) tmux select-window -t "$1" ;;
    herdr) "$herdr_bin" tab focus "$1" >/dev/null ;;
  esac
}

mux_kill_session() {
  local ws
  case "$mux" in
    tmux)
      if [ "$(mux_current_session)" = "$1" ]; then
        tmux switch-client -l 2>/dev/null || tmux switch-client -n 2>/dev/null || true
      fi
      tmux kill-session -t "=$1" 2>/dev/null || true
      ;;
    herdr)
      ws="$(herdr_workspace_id "$1")"
      if [ -n "$ws" ]; then
        "$herdr_bin" workspace close "$ws" >/dev/null || true
      fi
      ;;
  esac
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
  local src="$1" wt="$2" force="$3" bin
  if [ "$force" -eq 0 ] && [ -n "$(git -C "$wt" status --porcelain)" ]; then
    echo "tmt: $wt has uncommitted changes" >&2
    return 1
  fi
  bin="$trash_root/$(date +%s)-$$-$RANDOM"
  mkdir -p "$bin"
  mv "$wt" "$bin/"
  git -C "$src" worktree prune
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

  if mux_has_session "$session" && [ -z "$(window_id "$session" "$repo")" ]; then
    mux_new_window "$session" "$repo" "$target" >/dev/null
  fi
  echo "tmt: $repo -> $target ($branch from $start)"
}

ensure_herdr_workspace() {
  local dir="$1" session out pane r
  session="$(meta "$dir" session)"
  if ! mux_has_session "$session"; then
    out="$("$herdr_bin" workspace create --cwd "$dir" --label "$session" --no-focus)"
    pane="$(jq -r .result.root_pane.pane_id <<< "$out")"
    "$herdr_bin" tab rename "$(jq -r .result.tab.tab_id <<< "$out")" "1:claude" >/dev/null
    "$herdr_bin" pane run "$pane" "clear && $claude_cmd" >/dev/null
    while IFS= read -r r; do
      mux_new_window "$session" "$r" "$dir/$r" >/dev/null
    done < <(worktrees "$dir")
  fi
  echo "$session"
}

ensure_session() {
  local dir="$1" session pane r
  if [ "$mux" = herdr ]; then
    ensure_herdr_workspace "$dir"
    return 0
  fi
  session="$(meta "$dir" session)"
  if ! tmux has-session -t "=$session" 2>/dev/null; then
    pane="$(tmux new-session -d -P -F '#{pane_id}' -s "$session" -n claude -c "$dir")"
    tmux set-option -t "$pane" @tmt_task "$dir"
    tmux send-keys -t "$pane" "clear && $claude_cmd" Enter
    while IFS= read -r r; do
      tmux new-window -d -t "=$session:" -n "$r" -c "$dir/$r"
    done < <(worktrees "$dir")
  elif [ "$(tmux show-options -t "=$session:" -v @tmt_task 2>/dev/null)" != "$dir" ]; then
    die "tmux session '$session' exists but does not belong to this task"
  fi
  echo "$session"
}

attach() {
  if [ "$mux" = herdr ]; then
    "$herdr_bin" workspace focus "$(herdr_workspace_id "$1")" >/dev/null
  elif [ -n "${TMUX:-}" ]; then
    tmux switch-client -t "=$1"
  else
    tmux attach-session -t "=$1"
  fi
}

link_repos() {
  local dir="$1" base r name
  base="$(meta "$dir" base)"
  for r in "$base"/*/; do
    r="${r%/}"
    name="$(basename "$r")"
    if [ -e "$r/.git" ] && [ ! -e "$dir/$name" ] && [ ! -L "$dir/$name" ]; then
      ln -s "$r" "$dir/$name"
      echo "$name"
    fi
  done
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
  cmd_fresh "$base" || echo "tmt: fresh failed for $base, continuing" >&2
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

  link_repos "$dir" >/dev/null

  local r
  for r in "$@"; do
    add_repo "$dir" "$r"
  done
  write_claude_md "$dir"
  write_mcp_json "$dir"
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
  write_mcp_json "$dir"
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
    pr="$(pr_state "$src" "$b")"
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

  local tmp dir r i dirs=() repos=() pairs=()
  if [ "$with_pr" -eq 1 ]; then
    mapfile -t pairs < <(task_branches)
    prefetch_prs "${pairs[@]}"
  fi
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
        mux_has_session "$(meta "$dir" session)" || session=down
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
  local dir="$1" force="$2" assume_yes="$3" prompt_force="${4:-0}"
  local base session topic r dirty unpushed own pr b blocked=0 tmp pids=() srcs=()
  local -A status_of=() need_pr=()
  base="$(meta "$dir" base)"
  session="$(meta "$dir" session)"
  topic="$(meta "$dir" topic)"

  tmp="$(mktemp -d)"
  while IFS= read -r r; do
    repo_status "$dir/$r" "$base/$r" 0 > "$tmp/$r" &
    pids+=("$!")
  done < <(worktrees "$dir")
  [ "${#pids[@]}" -eq 0 ] || wait "${pids[@]}"

  while IFS= read -r r; do
    read -r dirty unpushed own pr b < "$tmp/$r"
    status_of[$r]="$dirty $unpushed $own $pr $b"
    if { [ "$own" -gt 0 ] || [ "$unpushed" -gt 0 ]; } &&
      { [ "$dirty" -eq 0 ] || [ "$force" -eq 1 ] || [ "$prompt_force" -eq 1 ]; }; then
      need_pr[$r]=1
      srcs+=("$base/$r"$'\t'"$b")
    fi
  done < <(worktrees "$dir")
  rm -rf "$tmp"
  prefetch_prs "${srcs[@]}"

  while IFS= read -r r; do
    read -r dirty unpushed own pr b <<< "${status_of[$r]}"
    if [ -n "${need_pr[$r]:-}" ]; then
      pr="$(pr_state "$base/$r" "$b")"
      status_of[$r]="$dirty $unpushed $own $pr $b"
    fi
    if ! is_safe "$dirty" "$unpushed" "$pr"; then
      echo "tmt: $r has dirty:$dirty unpushed:$unpushed pr:$pr" >&2
      blocked=1
    fi
  done < <(worktrees "$dir")
  if [ "$blocked" -eq 1 ] && [ "$force" -eq 0 ]; then
    if [ "$prompt_force" -eq 0 ]; then
      echo "tmt: refusing to remove $topic; pass -f to force" >&2
      exit 2
    fi
    gum confirm "force remove task $topic?" || exit 0
    force=1
    assume_yes=1
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
  mux_kill_session "$session"
}

cmd_close() {
  local session dir
  session="$(mux_current_session)"
  [ -n "$session" ] || die "not inside a $mux session"
  if ! dir="$(session_task "$session")"; then
    if gum confirm "close $session?"; then
      mux_kill_session "$session"
    fi
    return 0
  fi
  remove_task "$dir" 0 0 1
}

cmd_done() {
  local force=0 assume_yes=0 opt dir topic=""
  while [ "$#" -gt 0 ]; do
    OPTIND=1
    while getopts "fy" opt; do
      case "$opt" in
        f) force=1 ;;
        y) assume_yes=1 ;;
        *) usage >&2; exit 1 ;;
      esac
    done
    shift $((OPTIND - 1))
    if [ "$#" -gt 0 ]; then
      [ -z "$topic" ] || die "usage: tmt done [-f] [-y] [topic]"
      topic="$1"
      shift
    fi
  done
  dir="$(resolve_task "$topic")"
  remove_task "$dir" "$force" "$assume_yes"
}

merged_branches() {
  local src="$1" busy b oid
  busy="$(git -C "$src" worktree list --porcelain | sed -n 's|^branch refs/heads/||p')"
  if is_github "$src"; then
    (cd "$src" && gh pr list --state merged --author @me --limit 200 \
      --json headRefName,headRefOid -q '.[] | "\(.headRefName) \(.headRefOid)"' 2>/dev/null)
  else
    awk -F '\t' '$2 == "MERGED" { print $1, $3 }' "$(pr_file "$src")"
  fi |
    while read -r b oid; do
      if ! grep -qxF "$b" <<< "$busy" &&
        [ "$(git -C "$src" rev-parse --verify --quiet "refs/heads/$b")" = "$oid" ]; then
        printf '%s\t%s\n' "$src" "$b"
      fi
    done | sort -u
}

live_children() {
  local src="$1" wt="$2" stale="$3" busy def c
  busy="$(git -C "$src" worktree list --porcelain | sed -n 's|^branch refs/heads/||p')"
  def="$(start_ref "$src")"
  def="${def#origin/}"
  git -C "$wt" for-each-ref --contains HEAD --format='%(refname:short)' refs/heads |
    while IFS= read -r c; do
      if [ "$c" != "$def" ] && ! grep -qxF "$c" <<< "$busy" && ! grep -qxF "$src"$'\t'"$c" <<< "$stale"; then
        echo "$c"
      fi
    done
}

retire_worktree() {
  local dir="$1" r="$2" b="$3" base session id
  base="$(meta "$dir" base)"
  session="$(meta "$dir" session)"
  discard_worktree "$base/$r" "$dir/$r" 0
  git -C "$base/$r" branch -D "$b" >/dev/null
  ln -s "$base/$r" "$dir/$r"
  id="$(window_id "$session" "$r")" || id=""
  if [ -n "$id" ]; then
    mux_kill_window "$id"
  fi
  write_claude_md "$dir"
  write_mcp_json "$dir"
  echo "tmt: removed $(meta "$dir" topic)/$r worktree and branch $b"
}

cmd_gc() {
  local dir r src pairs=() srcs=()
  mapfile -t pairs < <(task_branches)
  prefetch_prs "${pairs[@]}"
  mapfile -t srcs < <(printf '%s\n' "${pairs[@]}" | cut -f1 | sort -u)

  local tmp i=0 stale_lines stale=() pids=()
  tmp="$(mktemp -d)"
  for src in "${srcs[@]}"; do
    [ -n "$src" ] || continue
    i=$((i + 1))
    merged_branches "$src" > "$tmp/$i" &
    pids+=("$!")
  done
  [ "${#pids[@]}" -eq 0 ] || wait "${pids[@]}"
  stale_lines="$(cat "$tmp"/* 2>/dev/null || true)"
  rm -rf "$tmp"
  [ -z "$stale_lines" ] || mapfile -t stale <<< "$stale_lines"

  local dirty unpushed own pr b n left wts candidates=() retired=()
  while IFS= read -r dir; do
    n=0
    left=0
    wts=()
    while IFS= read -r r; do
      n=$((n + 1))
      src="$(meta "$dir" base)/$r"
      read -r dirty unpushed own pr b < <(repo_status "$dir/$r" "$src")
      if [ "$dirty" -eq 0 ] && { [ "$pr" = MERGED ] || [ "$pr" = CLOSED ]; } &&
        [ -z "$(live_children "$src" "$dir/$r" "$stale_lines")" ]; then
        wts+=("$dir"$'\t'"$r"$'\t'"$b")
      else
        left=$((left + 1))
      fi
    done < <(worktrees "$dir")
    if [ "$n" -gt 0 ] && [ "$left" -eq 0 ]; then
      candidates+=("$dir")
    else
      retired+=("${wts[@]}")
    fi
  done < <(all_tasks)

  if [ "${#candidates[@]}" -eq 0 ] && [ "${#retired[@]}" -eq 0 ] && [ "${#stale[@]}" -eq 0 ]; then
    echo "tmt: nothing to clean up"
    return 0
  fi
  if [ "${#candidates[@]}" -gt 0 ]; then
    echo "tasks whose PRs are all merged or closed:"
    for dir in "${candidates[@]}"; do
      printf '  %s\t%s\t%s\n' "$(meta "$dir" topic)" "$(basename "$(meta "$dir" base)")" "$(worktrees "$dir" | tr '\n' ' ')"
    done | tabulate
  fi
  local entry
  if [ "${#retired[@]}" -gt 0 ]; then
    echo "worktrees whose PRs are merged or closed:"
    for entry in "${retired[@]}"; do
      IFS=$'\t' read -r dir r b <<< "$entry"
      printf '  %s\t%s\t%s\n' "$(meta "$dir" topic)" "$r" "$b"
    done | tabulate
  fi
  if [ "${#stale[@]}" -gt 0 ]; then
    echo "branches with merged PRs:"
    for src in "${stale[@]}"; do
      printf '  %s\t%s\n' "$(basename "${src%%$'\t'*}")" "${src#*$'\t'}"
    done | tabulate
  fi
  local reply
  read -r -p "Remove all of these? [y/N] " reply
  [ "$reply" = y ] || [ "$reply" = Y ] || die "aborted"
  for src in "${stale[@]}"; do
    git -C "${src%%$'\t'*}" branch -D "${src#*$'\t'}" >/dev/null
    echo "tmt: removed $(basename "${src%%$'\t'*}") branch ${src#*$'\t'}"
  done
  for entry in "${retired[@]}"; do
    IFS=$'\t' read -r dir r b <<< "$entry"
    retire_worktree "$dir" "$r" "$b"
  done
  empty_trash
  for dir in "${candidates[@]}"; do
    remove_task "$dir" 0 1
  done
}

paint() {
  printf '\033[%sm%s\033[0m' "$1" "$2"
}

fzf_pick() {
  local label="$1" preview="$2" frame
  shift 2
  if [ -n "${TMT_POPUP:-}" ]; then
    frame=(--border=none --input-border=line --input-label=" $label " --no-separator)
  else
    frame=(--border=rounded --border-label=" $label " --padding='0,1')
  fi
  fzf --ansi --layout=reverse --info=inline-right --highlight-line \
    --prompt='❯ ' --pointer='▌' --gutter=' ' --marker='▍' --separator='─' --scrollbar='│' \
    --color="$fzf_colors" \
    --delimiter='\t' --with-nth=2.. \
    --preview="$preview" --preview-window='right,55%,border-left,<60(down,50%,border-top)' \
    "${frame[@]}" "$@"
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
  local choice d session w=0 bw=0 t b state
  while IFS= read -r d; do
    t="$(meta "$d" topic)"
    b="$(basename "$(meta "$d" base)")"
    [ "${#t}" -le "$w" ] || w="${#t}"
    [ "${#b}" -le "$bw" ] || bw="${#b}"
  done < <(all_tasks)
  [ "$w" -gt 0 ] || die "no tasks under $root; run tmt create"
  choice="$(
    while IFS= read -r d; do
      if mux_has_session "$(meta "$d" session)"; then
        state="$(paint "$sgr_worktree" "running")"
      else
        state="$(paint "$sgr_main" "closed")"
      fi
      printf "%s\t%s %-${w}s  %s  %s\n" "$d" "$(paint "$sgr_root" "")" "$(meta "$d" topic)" \
        "$(paint "$sgr_dim" "$(printf "%-${bw}s" "$(basename "$(meta "$d" base)")")")" "$state"
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
      --expect=ctrl-a,ctrl-t \
      --header=":: $(paint "$sgr_accent" "<enter>") jump  $(paint "$sgr_accent" "<ctrl-a>") make worktree  $(paint "$sgr_accent" "<ctrl-t>") tasks"
  )" || return 0

  key="$(sed -n 1p <<< "$out")"
  if [ "$key" = ctrl-t ]; then
    pick_task
    return 0
  fi
  repo="$(sed -n 2p <<< "$out")"
  repo="${repo%%$'\t'*}"
  [ -n "$repo" ] || return 0

  if [ "$key" = ctrl-a ] && [ "$repo" != claude ]; then
    add_repo "$dir" "$repo"
    write_claude_md "$dir"
    write_mcp_json "$dir"
  fi

  id="$(window_id "$session" "$repo")"
  if [ -z "$id" ]; then
    id="$(mux_new_window "$session" "$repo" "$dir/$repo")"
  fi
  mux_select_window "$id"
}

candidate_bases() {
  local dir top d r
  {
    if dir="$(current_task)"; then
      meta "$dir" base
    fi
    if top="$(git rev-parse --show-toplevel 2>/dev/null)"; then
      dirname "$top"
    fi
    while IFS= read -r dir; do
      meta "$dir" base
    done < <(all_tasks)
    zoxide query -l 2>/dev/null || true
  } | awk '!seen[$0]++' | while IFS= read -r d; do
    for r in "$d"/*/.git; do
      if [ -e "$r" ]; then
        echo "$d"
        break
      fi
    done
  done
}

cmd_create() {
  local base topic choice repos=()
  base="$(
    candidate_bases | while IFS= read -r d; do
      printf '%s\t%s %s  %s\n' "$d" "$(paint "$sgr_root" "")" "$(basename "$d")" "$(paint "$sgr_dim" "$d")"
    done | fzf_pick "Base" "$0 _complete base-repos {1}" \
      --header=":: $(paint "$sgr_accent" "<enter>") pick base"
  )" || return 0
  base="${base%%$'\t'*}"

  topic="$(gum input --no-show-help --prompt "topic: " --placeholder "[A-Za-z0-9_-]+")" || return 0
  [ -n "$topic" ] || return 0

  while IFS= read -r choice; do
    repos+=("${choice%%$'\t'*}")
  done < <(
    cmd_complete base-repos "$base" | while IFS= read -r r; do
      printf '%s\t%s %s\n' "$r" "$(paint "$sgr_worktree" "")" "$r"
    done | fzf_pick "$topic" "$0 _preview repo $(printf '%q' "$base") {1}" --multi \
      --header=":: $(paint "$sgr_accent" "<tab>") select  $(paint "$sgr_accent" "<enter>") create worktrees"
  )
  [ "${#repos[@]}" -gt 0 ] || return 0

  cmd_new "$base" "$topic" "${repos[@]}"
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

  while IFS= read -r dir; do
    if [ "$(meta "$dir" base)" = "$base" ]; then
      while IFS= read -r r; do
        echo "tmt: linked $r into $(meta "$dir" topic)"
      done < <(link_repos "$dir")
      write_mcp_json "$dir"
    fi
  done < <(all_tasks)
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
  create) cmd_create ;;
  new) cmd_new "$@" ;;
  add) cmd_add "$@" ;;
  open) cmd_open "$@" ;;
  ls) cmd_ls "$@" ;;
  fresh) cmd_fresh "$@" ;;
  done) cmd_done "$@" ;;
  close) cmd_close ;;
  gc) cmd_gc ;;
  pick) cmd_pick ;;
  switch) pick_task ;;
  _preview) cmd_preview "$@" ;;
  _complete) cmd_complete "$@" ;;
  -h | --help | help) usage ;;
  *) usage >&2; exit 1 ;;
esac
