function copy_file_location()
  local bufname = vim.api.nvim_buf_get_name(0)
  local root = git_root_for_buf()
  local path
  if root and bufname:find(root, 1, true) then
    path = bufname:sub(#root + 2)
  else
    path = bufname
  end

  local mode = vim.fn.mode()
  local location
  if mode == 'v' or mode == 'V' then
    local l1 = vim.fn.line("v")
    local l2 = vim.fn.line(".")
    if l1 > l2 then l1, l2 = l2, l1 end
    if l1 == l2 then
      location = path .. ':' .. l1
    else
      location = path .. ':' .. l1 .. '-' .. l2
    end
  else
    location = path .. ':' .. vim.fn.line('.')
  end

  vim.fn.setreg('+', location)
  vim.notify(location, vim.log.levels.INFO)
end
