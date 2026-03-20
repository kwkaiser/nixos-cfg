function copy_github_url()
  local bufname = vim.api.nvim_buf_get_name(0)
  local line = vim.fn.line('.')
  local path
  local commit

  if vim.bo.filetype == 'DiffviewFiles' then
    local ok, lib = pcall(require, 'diffview.lib')
    if ok then
      local view = lib.get_current_view()
      if view and view.panel then
        local item = view.panel:get_item_at_cursor()
        if item then path = item.path end
      end
    end
  elseif bufname:match('^diffview://') then
    local hash, rest = bufname:match('%.git/(%x+)/(.+)$')
    if hash then
      path = rest
      commit = hash
    else
      path = bufname:match('%.git/:[^:]*:/(.+)$')
    end
  else
    local dir = vim.fn.fnamemodify(bufname, ':h')
    local root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(dir) .. ' rev-parse --show-toplevel')[1]
    if root and bufname:find(root, 1, true) then
      path = bufname:sub(#root + 2)
    end
  end

  if not path then
    vim.notify('Could not resolve file path', vim.log.levels.WARN)
    return
  end

  local target = path
  if not vim.bo.filetype:match('^Diffview') then
    target = path .. ':' .. line
  end

  -- Resolve the git root so gh browse runs in the right repo
  local git_root
  if bufname:match('^diffview://') or vim.bo.filetype:match('^Diffview') then
    local ok, lib = pcall(require, 'diffview.lib')
    if ok then
      local view = lib.get_current_view()
      if view and view.adapter then
        git_root = view.adapter.ctx.toplevel
      end
    end
  end
  if not git_root then
    git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  end

  local cmd = 'cd ' .. vim.fn.shellescape(git_root) .. ' && gh browse ' .. vim.fn.shellescape(target) .. ' --no-browser'
  if commit then
    cmd = cmd .. ' --branch ' .. commit
  end

  local result = vim.fn.systemlist(cmd .. ' 2>&1')
  if vim.v.shell_error ~= 0 then
    vim.notify('gh browse failed: ' .. (result[1] or ''), vim.log.levels.ERROR)
    return
  end

  local url = result[1]
  vim.fn.setreg('+', url)
  vim.notify(url, vim.log.levels.INFO)
end
