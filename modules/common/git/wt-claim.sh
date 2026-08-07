#!/usr/bin/env bash
set -euo pipefail

branch="${1:?usage: git wt-claim <branch> [target-worktree-path]}"
target="$(cd "${2:-.}" && pwd)"

git -C "$target" rev-parse --absolute-git-dir >/dev/null 2>&1 \
  || { echo "error: '$target' is not a git worktree" >&2; exit 1; }

holder="$(git worktree list --porcelain | awk -v b="refs/heads/$branch" '
  /^worktree / { path = $2 }
  /^branch /   { if ($2 == b) { print path; exit } }
')"
[[ -n "$holder" ]] && holder="$(cd "$holder" && pwd)"

if [[ -n "$holder" && "$holder" != "$target" ]]; then
  holder_gitdir="$(git -C "$holder" rev-parse --absolute-git-dir)"
  target_gitdir="$(git -C "$target" rev-parse --absolute-git-dir)"
  echo "$branch" >"$holder_gitdir/wt-displaced-branch"
  git -C "$holder" switch --detach --quiet
  echo "$holder" >"$target_gitdir/wt-displaced-holder"
  echo "displaced '$branch' from $holder (now detached)" >&2
fi

git -C "$target" switch "$branch"
