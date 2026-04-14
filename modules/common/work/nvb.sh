#!/usr/bin/env bash
# Pipe `tsc` build output (single-shot or --watch) to a neovim quickfix list.
#
# Typical usage from a monorepo root with tsconfig project references:
#   pnpm run build:check 2>&1 | nvb
#   pnpm run build:check --watch 2>&1 | nvb
#
# Notes:
# - The neovim instance must be listening on /tmp/nvim-<repo>.sock.
# - File paths are resolved to absolute paths against the git repo root so the
#   quickfix list works regardless of nvim's cwd (important when tsc -b emits
#   paths relative to the repo root, e.g. `packages/domain/src/...`).

set -uo pipefail

# --- socket / repo discovery -------------------------------------------------

if ! repo_root=$(git rev-parse --show-toplevel 2>/dev/null); then
  exec cat
fi
socket_path="/tmp/nvim-$(basename "$repo_root").sock"
if [[ ! -S "$socket_path" ]]; then
  exec cat
fi

luafile=$(mktemp "${TMPDIR:-/tmp}/nvb-lua.XXXXXXXX")
trap 'rm -f "$luafile"' EXIT

# --- path handling -----------------------------------------------------------

# Fallback prefix used when an error path is *not* already root-relative
# (e.g. running tsc directly inside a sub-package without `-b`).
cwd=$(pwd)
if [[ "$cwd" == "$repo_root" ]]; then
  cwd_rel=""
elif [[ "$cwd" == "$repo_root"/* ]]; then
  cwd_rel="${cwd#$repo_root/}"
else
  cwd_rel=""
fi
# Last `> pkg@x build:check /abs/path` header from pnpm overrides cwd_rel.
hdr_rel=""

# Decide whether a path emitted by tsc is already relative to the repo root
# by checking whether its first segment exists as a real entry under repo_root.
# This generalises the old hardcoded `packages/*` check to also cover
# `backend/...`, `frontend/...`, `scripts/...`, etc.
is_root_relative() {
  local f=$1
  local first=${f%%/*}
  [[ -n "$first" && "$first" != "$f" && -e "$repo_root/$first" ]]
}

resolve_path() {
  local f=$1
  if [[ "$f" = /* ]]; then
    printf '%s' "$f"
  elif is_root_relative "$f"; then
    printf '%s/%s' "$repo_root" "$f"
  else
    local prefix=${hdr_rel:-$cwd_rel}
    if [[ -n "$prefix" ]]; then
      printf '%s/%s/%s' "$repo_root" "$prefix" "$f"
    else
      printf '%s/%s' "$repo_root" "$f"
    fi
  fi
}

# --- ansi handling -----------------------------------------------------------

# Strip ANSI escapes using bash regex (no per-line fork to sed).
ansi_re=$'\x1b\\[[0-9;?]*[A-Za-z]'
strip_ansi() {
  local s=$1
  while [[ "$s" =~ $ansi_re ]]; do
    s=${s/"${BASH_REMATCH[0]}"/}
  done
  printf '%s' "$s"
}

# --- error buffering ---------------------------------------------------------

# Accumulated Lua `table.insert(...)` lines for the *current* compilation cycle.
errors=""
# A single in-progress error whose message may grow with continuation lines.
p_file=""; p_lnum=""; p_col=""; p_kind=""; p_msg=""

lua_escape() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

commit_pending() {
  [[ -z "$p_file" ]] && return 0
  local file msg
  file=$(lua_escape "$(resolve_path "$p_file")")
  msg=$(lua_escape "$p_msg")
  errors+="table.insert(items, {filename=\"$file\", lnum=$p_lnum, col=$p_col, text=\"$msg\", type=\"$p_kind\"})"$'\n'
  p_file=""; p_msg=""
}

flush_to_nvim() {
  commit_pending
  {
    echo 'local items = {}'
    printf '%s' "$errors"
    echo 'vim.fn.setqflist({}, "r", {title = "nvb", items = items})'
  } > "$luafile"
  # `<Cmd>` works in any mode (insert, visual, etc.) so this is safe even if
  # the user is editing when the flush arrives.
  nvim --server "$socket_path" --remote-send "<Cmd>luafile $luafile<CR>" \
    >/dev/null 2>&1 || true
  # Note: do NOT clear `errors` here. It is the authoritative set for the
  # current compile cycle; we want repeated flushes (idle-timeout, end-of-cycle)
  # to *replace* nvim's qf with the same growing set rather than wipe it.
  # `errors` is reset only at cycle-start markers below.
}

# --- patterns ----------------------------------------------------------------

# Pretty / watch:  src/foo.ts:21:7 - error TS2322: <msg>
re_pretty='^([^[:space:]][^:]*):([0-9]+):([0-9]+) - (error|warning) (.*)$'
# Plain (no --pretty):  src/foo.ts(21,7): error TS2322: <msg>
re_plain='^([^[:space:]][^(]*)\(([0-9]+),([0-9]+)\): (error|warning) (.*)$'
# pnpm script header:  > name@x.y build:check /abs/path
re_hdr='^> [^[:space:]]+ (build:check|build|tsc)([[:space:]]|:)'

# Code-frame lines that should NOT be appended to the message:
#   "428   type AssertionName,"  – line-number gutter
re_codeframe_num='^[[:space:]]*[0-9]+[[:space:]]'
#   "         ~~~~~~~~~~~~~"    – squiggly underline
re_codeframe_squig='^[[:space:]]*~+[[:space:]]*$'
# tsc watch timestamps come in two flavours depending on TTY/pretty mode:
#   "[10:20:31 AM] ..."   (TTY/pretty)
#   "10:20:31 AM - ..."   (piped/plain)
re_ts_timestamp='^\[[0-9]+:[0-9]+:[0-9]+ [AP]M\]|^[0-9]+:[0-9]+:[0-9]+ [AP]M -'

# End-of-cycle markers — any of these triggers a flush. In plain (piped) mode
# the "Watching for file changes" line can lag substantially behind the
# error stream, so we flush eagerly on the "Found N error(s)" summary too.
is_cycle_end() {
  local s=$1
  [[ "$s" == *"Watching for file changes"* ]] && return 0
  [[ "$s" == *"Compilation complete"* ]] && return 0
  [[ "$s" =~ Found\ [0-9]+\ error ]] && return 0
  return 1
}

# --- main loop ---------------------------------------------------------------

# Idle-timeout flush: if no input arrives for this many seconds and we have
# pending errors, push what we've got to nvim. This rescues the case where tsc
# (in non-TTY mode) batches its "Found N errors / Watching for file changes"
# line behind a stdio buffer for several seconds after the errors are emitted.
idle_secs=1
dirty=0   # 1 if `errors` (or pending) contains data not yet flushed

process_line() {
  local line=$1
  # Always pass-through original (with colors) so the user still sees tsc output.
  printf '%s\n' "$line"
  local clean
  clean=$(strip_ansi "$line")
  _process_clean "$line" "$clean"
}

# Wraps the original per-line logic; returns nothing but mutates state.
_process_clean() {
  local line=$1
  local clean=$2

  # pnpm script header: capture the directory pnpm ran the script from so we
  # can prefix bare relative paths if a sub-package emits any.
  if [[ "$clean" =~ $re_hdr ]]; then
    local abs=${clean##* }
    if [[ "$abs" == "$repo_root" ]]; then
      hdr_rel=""
    elif [[ "$abs" == "$repo_root"/* ]]; then
      hdr_rel="${abs#$repo_root/}"
    fi
    return
  fi

  # New compilation cycle starting — drop any half-collected state. The next
  # flush will replace nvim's qf with the fresh cycle's errors.
  if [[ "$clean" == *"Starting compilation in watch mode"* ]] \
    || [[ "$clean" == *"File change detected"* ]] \
    || [[ "$clean" == *"Starting incremental compilation"* ]]; then
    p_file=""; p_msg=""
    errors=""
    dirty=0
    return
  fi

  # End of a watch cycle (any of several wordings) — push to nvim.
  if is_cycle_end "$clean"; then
    flush_to_nvim
    dirty=0
    return
  fi

  # Strip a leading "[hh:mm:ss AM]" or "hh:mm:ss AM -" timestamp before
  # pattern-matching so non-error informational lines don't fool us.
  local stripped=$clean
  if [[ "$stripped" =~ $re_ts_timestamp ]]; then
    stripped=${stripped#"${BASH_REMATCH[0]}"}
    stripped=${stripped# }
  fi

  # Start of a new error/warning.
  if [[ "$stripped" =~ $re_pretty ]] || [[ "$stripped" =~ $re_plain ]]; then
    commit_pending
    p_file="${BASH_REMATCH[1]}"
    p_lnum="${BASH_REMATCH[2]}"
    p_col="${BASH_REMATCH[3]}"
    if [[ "${BASH_REMATCH[4]}" == "warning" ]]; then p_kind="W"; else p_kind="E"; fi
    p_msg="${BASH_REMATCH[5]}"
    dirty=1
    return
  fi

  # Possible continuation of the in-progress error message. tsc wraps long
  # messages (complex types) over multiple indented lines. Skip blank lines
  # and code-frame lines; commit the error when we hit a clear boundary.
  if [[ -n "$p_file" ]]; then
    if [[ -z "$stripped" ]]; then
      # Blank line — code frame is about to render in pretty mode, or end of
      # this error's continuation block in plain mode. Commit and move on.
      commit_pending
      return
    fi
    if [[ "$stripped" =~ $re_codeframe_num ]] \
      || [[ "$stripped" =~ $re_codeframe_squig ]]; then
      return
    fi
    # Indented continuation text — append to the in-progress message.
    if [[ "$clean" =~ ^[[:space:]] ]]; then
      local trimmed=${stripped#"${stripped%%[![:space:]]*}"}
      p_msg+=" $trimmed"
      return
    fi
    # Anything else ends the message.
    commit_pending
  fi
}

# Read loop with idle-timeout debounce. `read -t` returns >128 on timeout and
# 1 on EOF, so we can distinguish the two and flush appropriately.
while true; do
  if IFS= read -r -t "$idle_secs" line; then
    process_line "$line"
  else
    rc=$?
    if (( rc > 128 )); then
      # Idle: nothing arrived for $idle_secs. If we have collected anything
      # since the last flush, push it now so the user doesn't have to wait
      # for tsc's batched "Watching for file changes" line.
      if (( dirty )); then
        flush_to_nvim
        dirty=0
      fi
    else
      # rc == 1 → real EOF. Handle any final partial line.
      [[ -n "${line:-}" ]] && process_line "$line"
      break
    fi
  fi
done

# Single-shot (non-watch) mode: flush whatever we accumulated at EOF.
flush_to_nvim
