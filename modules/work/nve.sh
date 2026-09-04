#!/usr/bin/env bash
# Script to pipe eslint output to neovim quickfix list
# Usage: pnpm run lint 2>&1 | nve
set -euo pipefail

# Derive socket path from git repo
if ! git rev-parse --show-toplevel &>/dev/null; then
  cat
  exit 1
fi

repo_root=$(git rev-parse --show-toplevel)
repo_name=$(basename "$repo_root")
socket_path="/tmp/nvim-${repo_name}.sock"

if [[ ! -S "$socket_path" ]]; then
  cat
  exit 1
fi

luafile=$(mktemp /tmp/nve-lua.XXXXXX)
trap "rm -f $luafile" EXIT

current_file=""
errors=""

# Regex: "  line:col  error|warning  message  rule-name"
re_error='^[[:space:]]+([0-9]+):([0-9]+)[[:space:]]+(error|warning)[[:space:]]+(.+)[[:space:]]+[a-zA-Z0-9@/-]+$'

flush_errors() {
  {
    echo 'vim.fn.setqflist({}, "r")'
    echo 'local items = {}'
    echo -n "$errors"
    echo 'vim.fn.setqflist(items, "a")'
  } > "$luafile"

  nvim --server "$socket_path" --remote-send "<Cmd>luafile $luafile<CR>" 2>/dev/null || true
}

while IFS= read -r line || [[ -n "$line" ]]; do
  echo "$line"

  clean_line=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')

  # Absolute path line (starts with /) - new file context
  if [[ "$clean_line" =~ ^/ ]]; then
    # Convert absolute path to relative
    if [[ "$clean_line" == "$repo_root"/* ]]; then
      current_file="${clean_line#$repo_root/}"
    else
      current_file="$clean_line"
    fi
    continue
  fi

  # Error/warning line
  if [[ -n "$current_file" ]] && [[ "$clean_line" =~ $re_error ]]; then
    lnum="${BASH_REMATCH[1]}"
    col="${BASH_REMATCH[2]}"
    err_type="${BASH_REMATCH[3]}"
    msg="${BASH_REMATCH[4]}"

    # Escape for Lua
    msg="${msg//\\/\\\\}"
    msg="${msg//\"/\\\"}"
    escaped_file="${current_file//\\/\\\\}"
    escaped_file="${escaped_file//\"/\\\"}"

    type_char="E"
    [[ "$err_type" == "warning" ]] && type_char="W"

    errors="${errors}table.insert(items, {filename=\"${escaped_file}\", lnum=${lnum}, col=${col}, text=\"${msg}\", type=\"${type_char}\"})"$'\n'
  fi
done

flush_errors
