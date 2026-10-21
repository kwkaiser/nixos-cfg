local M = {}

local state = require("review-comments.state")
local diffview_ctx = require("review-comments.diffview")
local panel = require("review-comments.panel")

function M.setup()
  panel.setup()
end

--- Add a comment at the current cursor position in a diffview pane.
function M.add_comment()
  local ctx = diffview_ctx.get_cursor_context()
  if not ctx then return end

  local mode = vim.fn.mode()
  if mode ~= "n" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  end

  local comment = {
    file = ctx.file,
    side = ctx.side,
    line_start = ctx.line_start,
    line_end = ctx.line_end,
    comment = "",
    bufnr = ctx.bufnr,
  }
  state.add(comment)
  panel.focus(comment)
end

function M.delete_comment()
  local ctx = diffview_ctx.get_cursor_context()
  if not ctx then return end

  local comment = state.find(ctx.file, ctx.side, ctx.line_start)
  if not comment then
    vim.notify("No comment on this line", vim.log.levels.WARN)
    return
  end

  state.remove(comment)
  panel.refresh()
  vim.notify(string.format("Comment deleted: %s:%d", comment.file, comment.line_start), vim.log.levels.INFO)
end

function M.focus_panel()
  if not panel.enter() then
    vim.cmd("wincmd j")
  end
end

local preamble = "This is a structured review block. Please address comments or answer questions."

local function attr(value)
  return (tostring(value):gsub('"', "&quot;"))
end

local function indent(depth, lines)
  local pad = string.rep("  ", depth)
  return vim.tbl_map(function(line)
    return line == "" and line or pad .. line
  end, lines)
end

local function format_comment(c)
  local range = c.line_start == c.line_end and tostring(c.line_start)
    or string.format("%d-%d", c.line_start, c.line_end)
  local lines = { string.format('<comment lines="%s" side="%s">', range, attr(c.side)) }

  if vim.api.nvim_buf_is_valid(c.bufnr) then
    local code = vim.api.nvim_buf_get_lines(c.bufnr, c.line_start - 1, c.line_end, false)
    if #code > 0 then
      table.insert(lines, "  <code>")
      vim.list_extend(lines, indent(2, code))
      table.insert(lines, "  </code>")
    end
  end

  table.insert(lines, "  <feedback>")
  vim.list_extend(lines, indent(2, vim.split(vim.trim(c.comment), "\n")))
  vim.list_extend(lines, { "  </feedback>", "</comment>" })
  return lines
end

local function format_comments(comments)
  local by_file, order = {}, {}
  for _, c in ipairs(comments) do
    if not by_file[c.file] then
      by_file[c.file] = {}
      table.insert(order, c.file)
    end
    table.insert(by_file[c.file], c)
  end

  local lines = { "<review>" }
  for _, file in ipairs(order) do
    local group = by_file[file]
    table.sort(group, function(a, b)
      if a.side ~= b.side then return a.side == "old" end
      return a.line_start < b.line_start
    end)
    table.insert(lines, string.format('  <file path="%s">', attr(file)))
    for _, c in ipairs(group) do
      vim.list_extend(lines, indent(2, format_comment(c)))
    end
    table.insert(lines, "  </file>")
  end
  table.insert(lines, "</review>")

  local body = table.concat(lines, "\n")
  local longest = 0
  for run in body:gmatch("`+") do
    longest = math.max(longest, #run)
  end
  local fence = string.rep("`", math.max(3, longest + 1))
  return preamble .. "\n\n" .. fence .. "\n" .. body .. "\n" .. fence .. "\n"
end

--- Flush all comments to clipboard as XML and clear state.
function M.flush()
  if state.is_empty() then
    vim.notify("No comments to flush", vim.log.levels.INFO)
    return
  end

  local comments = state.get_all()
  vim.fn.setreg("+", format_comments(comments))
  local count = #comments
  state.clear()
  panel.hide()
  vim.notify(string.format("Flushed %d comment(s) to clipboard", count), vim.log.levels.INFO)
end

--- Flush comments then close diffview.
function M.submit()
  M.flush()
  vim.cmd("DiffviewClose")
end

--- Discard all comments and close diffview.
function M.abort()
  local count = #state.get_all()
  state.clear()
  panel.hide()
  vim.cmd("DiffviewClose")
  if count > 0 then
    vim.notify(string.format("Discarded %d comment(s)", count), vim.log.levels.INFO)
  end
end

return M
