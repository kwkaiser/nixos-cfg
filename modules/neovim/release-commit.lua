-- Find the earliest GitHub release whose tag contains a given commit
local function find_release_url(hash, git_root)
  local cd_prefix = 'cd ' .. vim.fn.shellescape(git_root) .. ' && '

  -- Ask GitHub for all release tags (url not available from list, fetch separately)
  local releases = vim.fn.systemlist(
    cd_prefix .. 'gh release list --limit 100 --json tagName 2>&1'
  )
  if vim.v.shell_error ~= 0 or not releases or #releases == 0 then
    return nil, nil, 'gh release list failed: ' .. (releases[1] or '')
  end

  local json = table.concat(releases, '')
  local decoded = vim.fn.json_decode(json)
  if not decoded or #decoded == 0 then
    return nil, nil, 'No releases found in repo'
  end

  -- For each release tag, check if our commit is an ancestor (i.e. the tag contains the commit)
  local matched_tag
  for _, release in ipairs(decoded) do
    vim.fn.system(
      cd_prefix .. 'git merge-base --is-ancestor ' .. vim.fn.shellescape(hash)
        .. ' ' .. vim.fn.shellescape(release.tagName) .. ' 2>/dev/null'
    )
    if vim.v.shell_error == 0 then
      matched_tag = release.tagName
      break
    end
  end

  if not matched_tag then
    return nil, nil, 'Commit ' .. hash:sub(1, 8) .. ' not found in any of the last 100 releases'
  end

  local url_result = vim.fn.systemlist(
    cd_prefix .. 'gh release view ' .. vim.fn.shellescape(matched_tag) .. ' --json url --jq ".url" 2>&1'
  )
  if vim.v.shell_error ~= 0 or not url_result or #url_result == 0 then
    return nil, nil, 'gh release view failed for tag ' .. matched_tag
  end

  return matched_tag, url_result[1], nil
end

function copy_commit_release_url()
  local hash, git_root, err = resolve_commit_context()
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  local tag, url, find_err = find_release_url(hash, git_root)
  if not url then
    vim.notify(find_err or 'No release found', vim.log.levels.WARN)
    return
  end

  vim.fn.setreg('+', url)
  vim.notify('Copied release ' .. tag .. ' URL', vim.log.levels.INFO)
end

function open_commit_release()
  local hash, git_root, err = resolve_commit_context()
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  local tag, url, find_err = find_release_url(hash, git_root)
  if not url then
    vim.notify(find_err or 'No release found', vim.log.levels.WARN)
    return
  end

  vim.ui.open(url)
  vim.notify('Opened release ' .. tag, vim.log.levels.INFO)
end
