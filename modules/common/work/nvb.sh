#!/usr/bin/env bash
# Script to pipe build output to neovim quickfix list
# Usage: pnpm run build:check 2>&1 | nvb
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

# Create temp files
rawfile=$(mktemp /tmp/nvb-raw.XXXXXX)
luafile=$(mktemp /tmp/nvb-lua.XXXXXX)
trap "rm -f $rawfile $luafile" EXIT

# Save all input and display
cat > "$rawfile"
cat "$rawfile"

# Parse errors and generate Lua code to set quickfix list
# Strip ANSI codes, track package context, extract error info
sed 's/\x1b\[[0-9;]*m//g' "$rawfile" | \
gawk -v repo_root="$repo_root" '
  BEGIN {
    print "vim.fn.setqflist({}, \"r\")"  # Clear existing quickfix list
    print "local items = {}"
  }

  # pnpm header line - extract package directory
  /^> .* build:check / {
    pkg_abs_path = $NF
    if (index(pkg_abs_path, repo_root) == 1) {
      pkg_rel_path = substr(pkg_abs_path, length(repo_root) + 2)
    } else {
      pkg_rel_path = ""
    }
    next
  }

  # TypeScript error: file.ts(21,7): error TS2322: message
  match($0, /^([^(]+)\(([0-9]+),([0-9]+)\): (error|warning) (.*)$/, m) {
    filename = m[1]
    if (pkg_rel_path != "") {
      filename = pkg_rel_path "/" filename
    }
    lnum = m[2]
    col = m[3]
    err_type = (m[4] == "error") ? "E" : "W"
    msg = m[5]
    # Escape quotes and backslashes for Lua string
    gsub(/\\/, "\\\\", msg)
    gsub(/"/, "\\\"", msg)
    gsub(/\\/, "\\\\", filename)
    gsub(/"/, "\\\"", filename)
    printf "table.insert(items, {filename=\"%s\", lnum=%s, col=%s, text=\"%s\", type=\"%s\"})\n", filename, lnum, col, msg, err_type
    next
  }

  END {
    print "vim.fn.setqflist(items, \"a\")"  # Append items to cleared list
  }
' > "$luafile"

# Execute the Lua file in neovim
nvim --server "$socket_path" --remote-send "<Cmd>luafile $luafile<CR>"

# Brief pause to let nvim read the file before cleanup
sleep 0.1
