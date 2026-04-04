#!/usr/bin/env bash
# Script to pipe build output to neovim quickfix list
# Usage: pnpm run build:check 2>&1 | nvb
# Watch: pnpm run build:check --watch 2>&1 | nvb
set -euo pipefail

# Derive socket path from git repo
if ! git rev-parse --show-toplevel &>/dev/null; then
  cat  # Still drain stdin
  exit 1
fi

repo_root=$(git rev-parse --show-toplevel)
repo_name=$(basename "$repo_root")
socket_path="/tmp/nvim-${repo_name}.sock"

if [[ ! -S "$socket_path" ]]; then
  cat  # Still drain stdin
  exit 1
fi

# Temp file for Lua commands
luafile=$(mktemp /tmp/nvb-lua.XXXXXX)
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

flush_errors() {
  # Generate Lua to set quickfix
  {
    echo 'vim.fn.setqflist({}, "r")'
    echo 'local items = {}'
    echo -n "$errors"
    echo 'vim.fn.setqflist(items, "a")'
  } > "$luafile"

  nvim --server "$socket_path" --remote-send "<Cmd>luafile $luafile<CR>" 2>/dev/null || true
  errors=""
}

# Regex patterns stored in variables for bash compatibility
re_watch_colon='^([^:]+):([0-9]+):([0-9]+) - (error|warning) (.*)$'
re_batch_paren='^([^(]+)\(([0-9]+),([0-9]+)\): (error|warning) (.*)$'
re_pnpm_header='^> .* build:check '

parse_error_line() {
  local line="$1"
  local filename lnum col err_type msg

  # Try format 1: file.ts:21:7 - error TS2322: message (watch mode / pretty)
  if [[ "$line" =~ $re_watch_colon ]]; then
    filename="${BASH_REMATCH[1]}"
    lnum="${BASH_REMATCH[2]}"
    col="${BASH_REMATCH[3]}"
    err_type="${BASH_REMATCH[4]}"
    msg="${BASH_REMATCH[5]}"
  # Try format 2: file.ts(21,7): error TS2322: message (batch mode)
  elif [[ "$line" =~ $re_batch_paren ]]; then
    filename="${BASH_REMATCH[1]}"
    lnum="${BASH_REMATCH[2]}"
    col="${BASH_REMATCH[3]}"
    err_type="${BASH_REMATCH[4]}"
    msg="${BASH_REMATCH[5]}"
  else
    return 1
  fi

  # Prepend package path only if filename is not already repo-root-relative
  if [[ -n "$pkg_rel_path" ]] && [[ "$filename" != packages/* ]]; then
    filename="${pkg_rel_path}/${filename}"
  fi

  # Escape for Lua
  msg="${msg//\\/\\\\}"
  msg="${msg//\"/\\\"}"
  filename="${filename//\\/\\\\}"
  filename="${filename//\"/\\\"}"

  local type_char="E"
  [[ "$err_type" == "warning" ]] && type_char="W"

  errors="${errors}table.insert(items, {filename=\"${filename}\", lnum=${lnum}, col=${col}, text=\"${msg}\", type=\"${type_char}\"})"$'\n'
  return 0
}

# Process line by line for both batch and watch mode
while IFS= read -r line || [[ -n "$line" ]]; do
  # Strip ANSI codes for parsing
  clean_line=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')

  # Always echo original line (preserves colors if any)
  echo "$line"

  # Watch mode: detect new compilation cycle - reset errors but keep cwd-based path
  if [[ "$clean_line" == *"Starting compilation"* ]] || [[ "$clean_line" == *"File change detected"* ]]; then
    errors=""
    continue
  fi

  # Watch mode: end of cycle - flush errors
  if [[ "$clean_line" == *"Watching for file changes"* ]]; then
    flush_errors
    continue
  fi

  # pnpm header - extract package directory
  if [[ "$clean_line" =~ $re_pnpm_header ]]; then
    pkg_abs_path="${clean_line##* }"
    if [[ "$pkg_abs_path" == "$repo_root"* ]]; then
      pkg_rel_path="${pkg_abs_path#$repo_root/}"
    else
      pkg_rel_path=""
    fi
    continue
  fi

  # Try to parse as error line
  parse_error_line "$clean_line" || true

done

# Batch mode: flush any remaining errors at EOF
flush_errors
