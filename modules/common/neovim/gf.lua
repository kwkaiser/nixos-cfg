-- Smart gf: opens in current window if no splits, prompts for window selection if splits exist
local function get_normal_windows()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local normal_wins = {}

  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local bt = vim.bo[buf].buftype
    local cfg = vim.api.nvim_win_get_config(win)
    -- Filter to normal buffers, exclude floating windows
    if bt == '' and cfg.relative == '' then
      table.insert(normal_wins, win)
    end
  end

  return normal_wins
end

local function get_window_display(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local name = vim.api.nvim_buf_get_name(buf)
  if name ~= '' then
    return vim.fn.fnamemodify(name, ':~:.')
  else
    return '[No Name]'
  end
end

_G.smart_gf = function()
  local file = vim.fn.expand('<cfile>')

  -- If file doesn't exist, fall back to default gf (searches path)
  if vim.fn.filereadable(file) == 0 then
    local ok, _ = pcall(vim.cmd, 'normal! gf')
    if not ok then
      vim.notify('File not found: ' .. file, vim.log.levels.WARN)
    end
    return
  end

  local normal_wins = get_normal_windows()

  if #normal_wins <= 1 then
    -- Single window (or only terminal/floating): just open the file
    if vim.bo.buftype == 'terminal' then
      -- If we're in terminal, open in a split instead
      vim.cmd('vsplit ' .. vim.fn.fnameescape(file))
    else
      vim.cmd('edit ' .. vim.fn.fnameescape(file))
    end
  else
    -- Multiple windows: use fzf-lua to pick
    local items = {}
    local win_map = {}

    for _, win in ipairs(normal_wins) do
      local display = get_window_display(win)
      table.insert(items, display)
      win_map[display] = win
    end

    require('fzf-lua').fzf_exec(items, {
      prompt = 'Open in window> ',
      actions = {
        ['default'] = function(selected)
          if selected and selected[1] then
            local win = win_map[selected[1]]
            if win then
              vim.api.nvim_set_current_win(win)
              vim.cmd('edit ' .. vim.fn.fnameescape(file))
            end
          end
        end
      }
    })
  end
end

vim.keymap.set('n', 'gf', _G.smart_gf, { desc = 'Smart go to file' })
