-- Shared: resolve commit hash and git root from diffview context
local function resolve_commit_context()
  local hash

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

  if not hash then
    local bufname = vim.api.nvim_buf_get_name(0)
    hash = bufname:match('%.git/(%x+)/')
  end

  if not hash then
    return nil, nil, 'No commit found under cursor'
  end

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

  return hash, git_root, nil
end

-- Shared: find PR URL for a commit hash
local function find_pr_url(hash, git_root)
  local cd_prefix = 'cd ' .. vim.fn.shellescape(git_root) .. ' && '

  local result = vim.fn.systemlist(cd_prefix .. 'gh pr list --search ' .. vim.fn.shellescape(hash) .. ' --state merged --json number,url --jq ".[0]" 2>&1')
  local json = result[1]

  if not json or json == '' or json == 'null' then
    result = vim.fn.systemlist(cd_prefix .. 'gh pr list --search ' .. vim.fn.shellescape(hash) .. ' --state open --json number,url --jq ".[0]" 2>&1')
    json = result[1]
  end

  if not json or json == '' or json == 'null' then
    return nil, nil
  end

  local decoded = vim.fn.json_decode(json)
  if decoded then
    return decoded.number, decoded.url
  end
  return nil, nil
end

function copy_commit_pr_url()
  local hash, git_root, err = resolve_commit_context()
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  local pr_number, pr_url = find_pr_url(hash, git_root)
  if not pr_url then
    vim.notify('No PR found for commit ' .. hash:sub(1, 8), vim.log.levels.WARN)
    return
  end

  vim.fn.setreg('+', pr_url)
  vim.notify('Copied PR #' .. pr_number .. ' URL', vim.log.levels.INFO)
end

function open_commit_pr()
  local hash, git_root, err = resolve_commit_context()
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  local pr_number, pr_url = find_pr_url(hash, git_root)
  if not pr_url then
    vim.notify('No PR found for commit ' .. hash:sub(1, 8), vim.log.levels.WARN)
    return
  end

  vim.ui.open(pr_url)
  vim.notify('Opened PR #' .. pr_number, vim.log.levels.INFO)
end
