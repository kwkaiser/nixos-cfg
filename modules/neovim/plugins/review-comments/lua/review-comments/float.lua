local M = {}

--- Open a floating input window for a comment.
---@param opts { title: string, on_confirm: fun(text: string), on_cancel: fun() }
function M.open(opts)
  local width = math.min(60, vim.o.columns - 10)
  local height = 5
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].filetype = "markdown"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = " " .. (opts.title or "Comment") .. " ",
    title_pos = "center",
  })

  -- Disable autocomplete in the float
  local cmp_ok, cmp = pcall(require, "cmp")
  if cmp_ok then
    cmp.setup.buffer({ enabled = false })
  end

  vim.cmd("startinsert")

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  -- Normal mode <CR>: confirm
  vim.keymap.set("n", "<CR>", function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    -- Trim trailing empty lines
    while #lines > 0 and lines[#lines]:match("^%s*$") do
      table.remove(lines)
    end
    local text = table.concat(lines, "\n")
    close()
    if text ~= "" then
      opts.on_confirm(text)
    else
      opts.on_cancel()
    end
  end, { buffer = buf, noremap = true, silent = true })

  -- Normal mode <Esc>: cancel
  vim.keymap.set("n", "<Esc>", function()
    close()
    opts.on_cancel()
  end, { buffer = buf, noremap = true, silent = true })
end

return M
