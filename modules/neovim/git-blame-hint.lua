local function close_blame_hint(winid)
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_win_close(winid, true)
  end
end

function git_blame_hint()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == '' then
    return
  end

  local root = git_root_for_buf()
  local dir = root or vim.fn.fnamemodify(bufname, ':h')
  local path = bufname
  if root and bufname:find(root, 1, true) then
    path = bufname:sub(#root + 2)
  end

  local lnum = vim.fn.line('.')
  local result = vim.fn.systemlist(
    'git -C ' .. vim.fn.shellescape(dir)
    .. ' blame -L ' .. lnum .. ',' .. lnum .. ' --porcelain -- ' .. vim.fn.shellescape(path)
  )
  if vim.v.shell_error ~= 0 or #result == 0 then
    vim.notify('git blame failed', vim.log.levels.WARN)
    return
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
    vim.notify('Not committed yet', vim.log.levels.INFO)
    return
  end

  local date = author_time and os.date('%Y-%m-%d %H:%M', author_time) or ''
  local lines = {
    sha:sub(1, 8) .. '  ' .. (author or '') .. '  ' .. date,
    summary or '',
  }

  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, #l)
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false

  local winid = vim.api.nvim_open_win(bufnr, true, {
    relative = 'cursor',
    row = 1,
    col = 0,
    width = width + 1,
    height = #lines,
    style = 'minimal',
    border = 'rounded',
  })

  local function close()
    close_blame_hint(winid)
  end

  vim.keymap.set('n', 'y', function()
    vim.fn.setreg('+', sha)
    vim.notify('Copied ' .. sha, vim.log.levels.INFO)
    close()
  end, { buffer = bufnr, silent = true, nowait = true })

  vim.keymap.set('n', 'q', close, { buffer = bufnr, silent = true, nowait = true })
  vim.keymap.set('n', '<Esc>', close, { buffer = bufnr, silent = true, nowait = true })

  vim.api.nvim_create_autocmd('WinLeave', {
    buffer = bufnr,
    once = true,
    callback = close,
  })
end
