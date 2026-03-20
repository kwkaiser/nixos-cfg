function git_root_for_buf()
  local bufname = vim.api.nvim_buf_get_name(0)
  local dir
  if bufname ~= '' and not bufname:match('^diffview://') then
    dir = vim.fn.fnamemodify(bufname, ':h')
  end
  if dir and dir ~= '' then
    return vim.fn.systemlist('git -C ' .. vim.fn.shellescape(dir) .. ' rev-parse --show-toplevel')[1]
  end
  return vim.fn.systemlist('git rev-parse --show-toplevel')[1]
end
