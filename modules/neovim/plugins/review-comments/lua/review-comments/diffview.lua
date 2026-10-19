local M = {}

--- Map diffview's "a"/"b" symbols to "old"/"new"
local side_map = { a = "old", b = "new" }

--- Get cursor context from the current diffview buffer.
--- Returns nil if not in a diffview diff pane.
---@return { file: string, side: "old"|"new", line_start: integer, line_end: integer, bufnr: integer }|nil
function M.get_cursor_context(opts)
  local quiet = opts and opts.quiet
  local function warn(msg, level)
    if not quiet then vim.notify(msg, level or vim.log.levels.WARN) end
  end

  local ok, lib = pcall(require, "diffview.lib")
  if not ok then
    warn("diffview not available", vim.log.levels.ERROR)
    return nil
  end

  local view = lib.get_current_view()
  if not view or not view.cur_layout then
    warn("No active diffview")
    return nil
  end

  local curwin = vim.api.nvim_get_current_win()
  local layout = view.cur_layout

  local side_symbol
  if layout.a and layout.a.id == curwin then
    side_symbol = "a"
  elseif layout.b and layout.b.id == curwin then
    side_symbol = "b"
  else
    warn("Place cursor in a diff pane to add a comment")
    return nil
  end

  local file_entry = view:infer_cur_file()
  if not file_entry or not file_entry.path then
    warn("Could not determine file")
    return nil
  end

  local cursor = vim.api.nvim_win_get_cursor(curwin)
  local line_start = cursor[1]
  local line_end = line_start

  -- Check for visual mode selection
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    local vs = vim.fn.getpos("v")[2]
    local ve = cursor[1]
    line_start = math.min(vs, ve)
    line_end = math.max(vs, ve)
  end

  return {
    file = file_entry.path,
    side = side_map[side_symbol],
    line_start = line_start,
    line_end = line_end,
    bufnr = vim.api.nvim_get_current_buf(),
  }
end

return M
