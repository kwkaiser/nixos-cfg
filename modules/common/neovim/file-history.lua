function open_file_history()
  local path
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
  end

  if path then
    vim.cmd('DiffviewFileHistory ' .. path .. ' --follow')
  else
    vim.cmd('DiffviewFileHistory % --follow')
  end
end
