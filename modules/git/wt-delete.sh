#!/usr/bin/env bash
set -uo pipefail

[[ $# -gt 0 ]] || { echo "usage: git wt-delete <branch>..." >&2; exit 1; }

here="$(pwd -P)"

for branch in "$@"; do
  path="$(git worktree list --porcelain | awk -v b="refs/heads/$branch" '
    /^worktree / { path = $2 }
    /^branch /   { if ($2 == b) { print path; exit } }
  ')"
  if [[ -n "$path" ]] && [[ "$(cd "$path" && pwd -P)" != "$here" ]]; then
    git worktree remove --force "$path" && echo "removed worktree $path (was on '$branch')" >&2
  fi
done

git branch -D "$@"
