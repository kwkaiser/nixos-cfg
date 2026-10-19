local M = {}

local state = require("review-comments.state")
local diffview_ctx = require("review-comments.diffview")

local height = 5
local group = vim.api.nvim_create_augroup("review_comments_panel", { clear = true })

local buf, win, source_win, current

local function win_valid()
  return win ~= nil and vim.api.nvim_win_is_valid(win)
end

local function buf_text()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  while #lines > 0 and lines[#lines]:match("^%s*$") do
    table.remove(lines)
  end
  return table.concat(lines, "\n")
end

local function float_config()
  local ok, lib = pcall(require, "diffview.lib")
  local view = ok and lib.get_current_view()
  local layout = view and view.cur_layout
  if not layout then return end

  local top, left, bottom, right
  for _, w in ipairs(layout.windows) do
    if w.id and vim.api.nvim_win_is_valid(w.id) then
      local pos = vim.api.nvim_win_get_position(w.id)
      local r2 = pos[1] + vim.api.nvim_win_get_height(w.id)
      local c2 = pos[2] + vim.api.nvim_win_get_width(w.id)
      top = math.min(top or pos[1], pos[1])
      left = math.min(left or pos[2], pos[2])
      bottom = math.max(bottom or r2, r2)
      right = math.max(right or c2, c2)
    end
  end
  if not top then return end

  local row = bottom - height - 1
  local border = { "", "─", "", "", "", "", "", "" }
  if source_win and vim.api.nvim_win_is_valid(source_win) then
    local cursor_row = vim.api.nvim_win_get_position(source_win)[1]
      + vim.api.nvim_win_call(source_win, vim.fn.winline) - 1
    if cursor_row >= row then
      row = top
      border = { "", "", "", "", "", "─", "", "" }
    end
  end

  return {
    relative = "editor",
    row = row,
    col = left,
    width = right - left,
    height = height,
    style = "minimal",
    border = border,
    focusable = true,
    zindex = 40,
  }
end

local function ensure_buf()
  if buf and vim.api.nvim_buf_is_valid(buf) then return end

  buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].filetype = "markdown"

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    buffer = buf,
    callback = function()
      if current then current.comment = buf_text() end
    end,
  })

  vim.api.nvim_create_autocmd("WinLeave", {
    group = group,
    buffer = buf,
    callback = function()
      if not current then return end
      current.comment = buf_text()
      if current.comment == "" then
        state.remove(current)
        current = nil
      end
    end,
  })

  vim.keymap.set("n", "<Esc>", M.leave, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set("n", "<CR>", M.leave, { buffer = buf, silent = true })
end

local function open_win()
  local tab = vim.api.nvim_get_current_tabpage()
  if win_valid() and vim.api.nvim_win_get_tabpage(win) ~= tab then
    vim.api.nvim_win_close(win, true)
  end

  local config = float_config()
  if not config then return false end

  if win_valid() then
    vim.api.nvim_win_set_config(win, config)
    return true
  end

  win = vim.api.nvim_open_win(buf, false, config)
  vim.wo[win].wrap = true
  vim.wo[win].winbar = ""
  vim.wo[win].winhighlight = "NormalFloat:DiffviewNormal,FloatBorder:DiffviewWinSeparator,EndOfBuffer:DiffviewEndOfBuffer"
  return true
end

function M.show(c)
  ensure_buf()
  if not open_win() then return end
  if current ~= c then
    current = c
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(c.comment, "\n"))
  end
end

function M.hide()
  if win_valid() then
    vim.api.nvim_win_close(win, true)
  end
  win, current = nil, nil
end

function M.focus(c)
  source_win = vim.api.nvim_get_current_win()
  M.show(c)
  vim.api.nvim_set_current_win(win)

  local cmp_ok, cmp = pcall(require, "cmp")
  if cmp_ok then
    cmp.setup.buffer({ enabled = false })
  end

  local last = vim.api.nvim_buf_line_count(buf)
  local line = vim.api.nvim_buf_get_lines(buf, last - 1, last, false)[1]
  vim.api.nvim_win_set_cursor(win, { last, #line })
  vim.cmd("startinsert!")
end

function M.enter()
  if not (win_valid() and current) then return false end
  source_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(win)
  return true
end

function M.leave()
  vim.cmd("stopinsert")
  if source_win and vim.api.nvim_win_is_valid(source_win) then
    vim.api.nvim_set_current_win(source_win)
  else
    vim.cmd("wincmd p")
  end
end

function M.refresh()
  if win_valid() and vim.api.nvim_get_current_win() == win then return end

  local ctx = diffview_ctx.get_cursor_context({ quiet = true })
  if ctx then
    source_win = vim.api.nvim_get_current_win()
    local c = state.find(ctx.file, ctx.side, ctx.line_start)
    if c then return M.show(c) end
  elseif current then
    return
  end
  M.hide()
end

function M.setup()
  vim.api.nvim_create_autocmd({ "CursorMoved", "WinEnter", "BufEnter", "WinResized", "VimResized" }, {
    group = group,
    callback = function()
      vim.schedule(M.refresh)
    end,
  })
end

return M
