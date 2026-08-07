#!/usr/bin/env bash
set -euo pipefail

worktree="$(cd "${1:-.}" && pwd)"
gitdir="$(git -C "$worktree" rev-parse --absolute-git-dir)"
holder_file="$gitdir/wt-displaced-holder"

if [[ -f "$holder_file" ]]; then
  holder="$(cat "$holder_file")"
  holder_gitdir="$(git -C "$holder" rev-parse --absolute-git-dir 2>/dev/null || true)"
  if [[ -n "$holder_gitdir" && -f "$holder_gitdir/wt-displaced-branch" ]]; then
    branch="$(cat "$holder_gitdir/wt-displaced-branch")"
    git -C "$worktree" switch --detach --quiet
    git -C "$holder" switch "$branch"
    rm -f "$holder_gitdir/wt-displaced-branch" "$holder_file"
    echo "restored '$branch' to $holder" >&2
    exit 0
  fi
  echo "warning: recorded holder '$holder' is no longer valid; clearing" >&2
  rm -f "$holder_file"
fi
