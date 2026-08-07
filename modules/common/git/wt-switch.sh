#!/usr/bin/env bash
set -euo pipefail

branch="${1:?usage: git wt-switch <branch> [target-worktree-path]}"
target="${2:-.}"

git-wt-release "$target"
git-wt-claim "$branch" "$target"
