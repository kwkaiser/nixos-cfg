function diff_commit_at_cursor()
  local hash, _, err = resolve_commit_context()
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  vim.cmd('DiffviewOpen ' .. hash .. '^..' .. hash)
end
