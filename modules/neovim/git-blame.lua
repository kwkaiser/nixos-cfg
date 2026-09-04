-- Returns blame info for a line, or nil on failure, or { uncommitted = true }.
function git_blame_info(bufname, lnum)
  if bufname == '' then
    return nil
  end

  local root = git_root_for_buf()
  local dir = root or vim.fn.fnamemodify(bufname, ':h')
  local path = bufname
  if root and bufname:find(root, 1, true) then
    path = bufname:sub(#root + 2)
  end

  local result = vim.fn.systemlist(
    'git -C ' .. vim.fn.shellescape(dir)
    .. ' blame -L ' .. lnum .. ',' .. lnum .. ' --porcelain -- ' .. vim.fn.shellescape(path)
  )
  if vim.v.shell_error ~= 0 or #result == 0 then
    return nil
  end

  local sha = result[1]:match('^(%x+)')
  local author, author_time, summary
  for _, l in ipairs(result) do
    if l:match('^author ') then
      author = l:sub(8)
    elseif l:match('^author%-time ') then
      author_time = tonumber(l:match('^author%-time (%d+)'))
    elseif l:match('^summary ') then
      summary = l:sub(9)
    end
  end

  if not sha or sha:match('^0+$') then
    return { uncommitted = true }
  end

  local short_sha = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(dir) .. ' rev-parse --short ' .. sha)[1]

  return {
    sha = sha,
    short_sha = short_sha,
    author = author,
    author_time = author_time,
    summary = summary,
  }
end
