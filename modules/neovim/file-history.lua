local function jump_file_history_to_commit(sha, attempts)
  attempts = attempts or 0

  local ok, lib = pcall(require, 'diffview.lib')
  if not ok then
    return
  end

  local view = lib.get_current_view()
  if view and view.panel then
    for _, entry in ipairs(view.panel.entries) do
      if entry.commit and entry.commit.hash == sha then
        view.panel:highlight_item(entry)
        view:set_file(entry.files[1], false)
        return
      end
    end
  end

  if attempts < 50 then
    vim.defer_fn(function() jump_file_history_to_commit(sha, attempts + 1) end, 100)
  else
    vim.notify('Commit not found in file history', vim.log.levels.WARN)
  end
end

function open_file_history()
  local path
  local jump_sha

  if vim.bo.filetype == 'DiffviewFiles' then
    local ok, lib = pcall(require, 'diffview.lib')
    if ok then
      local view = lib.get_current_view()
      if view and view.panel then
        local item = view.panel:get_item_at_cursor()
        if item then path = item.absolute_path end
      end
    end
  elseif vim.api.nvim_buf_get_name(0):match('^diffview://') then
    local bufname = vim.api.nvim_buf_get_name(0)
    path = bufname:match('%.git/:[^:]*:/(.+)$') or bufname:match('%.git/[^/]+/(.+)$')
  else
    local info = git_blame_info(vim.api.nvim_buf_get_name(0), vim.fn.line('.'))
    if info and not info.uncommitted then
      jump_sha = info.sha
    end
  end

  if path then
    vim.cmd('DiffviewFileHistory ' .. path .. ' --follow')
  else
    vim.cmd('DiffviewFileHistory % --follow')
  end

  if jump_sha then
    jump_file_history_to_commit(jump_sha)
  end
end
