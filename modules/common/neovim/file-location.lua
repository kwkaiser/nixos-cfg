function copy_file_location()
  local bufname = vim.api.nvim_buf_get_name(0)
  local root = git_root_for_buf()
  local path
  if root and bufname:find(root, 1, true) then
    path = bufname:sub(#root + 2)
  else
    path = bufname
  end

  local line = vim.fn.line('.')
  local location = path .. ':' .. line
  vim.fn.setreg('+', location)
  vim.notify(location, vim.log.levels.INFO)
end
