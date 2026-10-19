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

--- Flush all comments to clipboard as JSON and clear state.
function M.flush()
  if state.is_empty() then
    vim.notify("No comments to flush", vim.log.levels.INFO)
    return
  end

  local comments = state.get_all()
  local output = {}
  for _, c in ipairs(comments) do
    table.insert(output, {
      file = c.file,
      line_start = c.line_start,
      line_end = c.line_end,
      side = c.side,
      comment = c.comment,
    })
  end

  local json = vim.fn.json_encode({ comments = output })
  vim.fn.setreg("+", json)
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
