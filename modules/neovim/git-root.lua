function git_root_for_buf()
  local bufname = vim.api.nvim_buf_get_name(0)
  local dir
  if bufname ~= '' and not bufname:match('^diffview://') and not bufname:match('^term://') then
    dir = vim.fn.fnamemodify(bufname, ':h')
  end
  if dir and dir ~= '' then
    return vim.fn.systemlist('git -C ' .. vim.fn.shellescape(dir) .. ' rev-parse --show-toplevel')[1]
  end
  return vim.fn.systemlist('git rev-parse --show-toplevel')[1]
end

function diffview_range(root, base, branch)
  local git = 'git -C ' .. vim.fn.shellescape(root)
  local current = vim.fn.systemlist(git .. ' rev-parse --abbrev-ref HEAD')[1]
  if branch == current then
    local merge_base = vim.fn.systemlist(git .. ' merge-base ' .. vim.fn.shellescape(base) .. ' HEAD')[1]
    if vim.v.shell_error == 0 and merge_base then return merge_base end
    return base
  end
  return base .. '...' .. branch
end
