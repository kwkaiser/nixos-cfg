local locked = {}

local function unlock(keep)
  for bufnr, prev in pairs(locked) do
    if not (keep and keep[bufnr]) then
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.bo[bufnr].modifiable = prev.modifiable
        vim.bo[bufnr].readonly = prev.readonly
      end
      locked[bufnr] = nil
    end
  end
end

local function lock_current()
  local view = require('diffview.lib').get_current_view()
  if not view or not view.cur_layout then return unlock() end

  local RevType = require('diffview.vcs.rev').RevType
  local keep = {}
  for _, win in ipairs(view.cur_layout.windows) do
    local file = win.file
    local bufnr = file and file.bufnr
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) and file.rev and file.rev.type == RevType.LOCAL then
      keep[bufnr] = true
      if not locked[bufnr] then
        locked[bufnr] = { modifiable = vim.bo[bufnr].modifiable, readonly = vim.bo[bufnr].readonly }
      end
      vim.bo[bufnr].modifiable = false
      vim.bo[bufnr].readonly = true
    end
  end
  unlock(keep)
end

vim.api.nvim_create_autocmd('User', {
  group = vim.api.nvim_create_augroup('diffview_readonly', { clear = true }),
  pattern = { 'DiffviewDiffBufWinEnter', 'DiffviewViewEnter', 'DiffviewViewLeave', 'DiffviewViewClosed' },
  callback = function(ev)
    if ev.match == 'DiffviewDiffBufWinEnter' or ev.match == 'DiffviewViewEnter' then
      lock_current()
    else
      unlock()
    end
  end,
})
