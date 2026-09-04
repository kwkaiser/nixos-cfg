#!/usr/bin/env bash
# Script to pipe vitest output to neovim quickfix list
# Usage: pnpm run test 2>&1 | nvt
# Watch: pnpm run test --watch 2>&1 | nvt
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

luafile=$(mktemp /tmp/nvt-lua.XXXXXX)
trap "rm -f $luafile" EXIT

# Default package path: cwd relative to repo root
cwd=$(pwd)
if [[ "$cwd" == "$repo_root" ]]; then
  pkg_rel_path=""
elif [[ "$cwd" == "$repo_root"/* ]]; then
  pkg_rel_path="${cwd#$repo_root/}"
else
  pkg_rel_path=""
fi

errors=""
last_error_msg=""

flush_errors() {
  {
    echo 'vim.fn.setqflist({}, "r")'
    echo 'local items = {}'
    echo -n "$errors"
    echo 'vim.fn.setqflist(items, "a")'
  } > "$luafile"

  nvim --server "$socket_path" --remote-send "<Cmd>luafile $luafile<CR>" 2>/dev/null || true
  errors=""
}

# Regex: "filepath.ext:line:col" at end of line (vitest error location)
# Avoids depending on the ❯ arrow character which can vary by terminal/vitest version
re_location='([^[:space:]]+\.[a-z]+):([0-9]+):([0-9]+)[[:space:]]*$'
# Regex: "Error: message" or "AssertionError: message"
re_error_msg='(Error|AssertionError|TypeError|ReferenceError):[[:space:]]*(.*)$'

while IFS= read -r line || [[ -n "$line" ]]; do
  echo "$line"

  # Strip all ANSI/VT escape sequences (SGR, cursor movement, erase, mode changes, etc.)
  clean_line=$(echo "$line" | sed 's/\x1b\[[0-9;?]*[A-Za-z]//g; s/\x1b[()]//g')

  # Watch mode: detect new test cycle - reset errors
  if [[ "$clean_line" == *"RERUN"* ]] || [[ "$clean_line" == *"RUN"* && "$clean_line" == *"v"*"/"* ]]; then
    errors=""
    last_error_msg=""
    continue
  fi

  # Watch mode / batch mode: end of cycle - flush errors
  if [[ "$clean_line" == *"Watching for file changes"* ]] || [[ "$clean_line" == *"ELIFECYCLE"* ]]; then
    flush_errors
    continue
  fi

  # Capture error message for next location line
  if [[ "$clean_line" =~ $re_error_msg ]]; then
    last_error_msg="${BASH_REMATCH[2]}"
    continue
  fi

  # Error location line: "filepath.ext:line:col" at end of line
  if [[ "$clean_line" =~ $re_location ]]; then
    filename="${BASH_REMATCH[1]}"
    lnum="${BASH_REMATCH[2]}"
    col="${BASH_REMATCH[3]}"

    # Prepend package path if we have context
    if [[ -n "$pkg_rel_path" ]]; then
      filename="${pkg_rel_path}/${filename}"
    fi

    # Use captured error message or fallback
    msg="${last_error_msg:-Test failed}"

    # Escape for Lua
    msg="${msg//\\/\\\\}"
    msg="${msg//\"/\\\"}"
    filename="${filename//\\/\\\\}"
    filename="${filename//\"/\\\"}"

    errors="${errors}table.insert(items, {filename=\"${filename}\", lnum=${lnum}, col=${col}, text=\"${msg}\", type=\"E\"})"$'\n'
    last_error_msg=""
  fi
done

# Batch mode: flush any remaining errors at EOF (only if we have errors)
if [[ -n "$errors" ]]; then
  flush_errors
fi
