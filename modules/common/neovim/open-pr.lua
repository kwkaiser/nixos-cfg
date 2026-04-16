function open_commit_pr()
  local hash

  -- Try to get commit hash from diffview panel item under cursor
  local ok, lib = pcall(require, 'diffview.lib')
  if ok then
    local view = lib.get_current_view()
    if view and view.panel then
      local item = view.panel:get_item_at_cursor()
      if item and item.commit then
        hash = item.commit.hash
      end
    end
  end

  -- Fallback: try to extract hash from a diffview buffer name
  if not hash then
    local bufname = vim.api.nvim_buf_get_name(0)
    hash = bufname:match('%.git/(%x+)/')
  end

  if not hash then
    vim.notify('No commit found under cursor', vim.log.levels.WARN)
    return
  end

  -- Resolve git root for running gh
  local git_root
  if ok then
    local view = lib.get_current_view()
    if view and view.adapter then
      git_root = view.adapter.ctx.toplevel
    end
  end
  if not git_root then
    git_root = git_root_for_buf()
  end

  local cd_prefix = 'cd ' .. vim.fn.shellescape(git_root) .. ' && '

  -- Find the PR that contains this commit
  local result = vim.fn.systemlist(cd_prefix .. 'gh pr list --search ' .. vim.fn.shellescape(hash) .. ' --state merged --json number --jq ".[0].number" 2>&1')
  local pr_number = result[1]

  -- If not found in merged, try open PRs
  if not pr_number or pr_number == '' or pr_number == 'null' then
    result = vim.fn.systemlist(cd_prefix .. 'gh pr list --search ' .. vim.fn.shellescape(hash) .. ' --state open --json number --jq ".[0].number" 2>&1')
    pr_number = result[1]
  end

  if not pr_number or pr_number == '' or pr_number == 'null' then
    vim.notify('No PR found for commit ' .. hash:sub(1, 8), vim.log.levels.WARN)
    return
  end

  vim.fn.system(cd_prefix .. 'gh pr view ' .. pr_number .. ' --web')
  vim.notify('Opened PR #' .. pr_number, vim.log.levels.INFO)
end
