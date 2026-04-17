local M = {}

local state = require("review-comments.state")
local float = require("review-comments.float")
local diffview_ctx = require("review-comments.diffview")

function M.setup()
  -- Sign definition is lazy (on first comment), nothing else needed
end

--- Add a comment at the current cursor position in a diffview pane.
--- Opens a floating input. Works in normal and visual mode.
function M.add_comment()
  local ctx = diffview_ctx.get_cursor_context()
  if not ctx then return end

  local title
  if ctx.line_start == ctx.line_end then
    title = string.format("%s:%d (%s)", ctx.file, ctx.line_start, ctx.side)
  else
    title = string.format("%s:%d-%d (%s)", ctx.file, ctx.line_start, ctx.line_end, ctx.side)
  end

  -- Exit visual mode before opening float
  local mode = vim.fn.mode()
  if mode ~= "n" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  end

  float.open({
    title = title,
    on_confirm = function(text)
      state.add({
        file = ctx.file,
        side = ctx.side,
        line_start = ctx.line_start,
        line_end = ctx.line_end,
        comment = text,
        bufnr = ctx.bufnr,
      })
      vim.notify(string.format("Comment added: %s:%d", ctx.file, ctx.line_start), vim.log.levels.INFO)
    end,
    on_cancel = function() end,
  })
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
  vim.cmd("DiffviewClose")
  if count > 0 then
    vim.notify(string.format("Discarded %d comment(s)", count), vim.log.levels.INFO)
  end
end

return M
