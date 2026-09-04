function open_file_history()
  local path
  local target_sha

  if vim.bo.filetype == 'DiffviewFiles' then
    local ok, lib = pcall(require, 'diffview.lib')
    if ok then
      local cur_view = lib.get_current_view()
      if cur_view and cur_view.panel then
        local item = cur_view.panel:get_item_at_cursor()
        if item then path = item.absolute_path end
      end
    end
  elseif vim.api.nvim_buf_get_name(0):match('^diffview://') then
    local bufname = vim.api.nvim_buf_get_name(0)
    path = bufname:match('%.git/:[^:]*:/(.+)$') or bufname:match('%.git/[^/]+/(.+)$')
  else
    path = vim.api.nvim_buf_get_name(0)
    local info = git_blame_info(path, vim.fn.line('.'))
    if info and not info.uncommitted then
      target_sha = info.sha
    end
  end

  if not path then
    vim.notify('Could not resolve file path for history', vim.log.levels.WARN)
    return
  end

  local view = require('diffview.lib').file_history(nil, { path, '++follow' })
  if not view then
    return
  end

  view:open()

  if not target_sha then
    return
  end

  -- diffview auto-opens the diff for the first streamed log entry (HEAD)
  -- as soon as one arrives, via panel:next_file(). Neutering it until we
  -- find our target means that auto-open never fires, so the blamed
  -- commit's diff is the first (and only) one ever shown -- no flash of
  -- HEAD's diff first. The entry list itself still populates normally,
  -- since that isn't gated on next_file().
  local real_next_file = view.panel.next_file
  view.panel.next_file = function() return nil end

  local function restore()
    view.panel.next_file = real_next_file
  end

  local function poll(attempts)
    attempts = attempts or 0

    for _, entry in ipairs(view.panel.entries) do
      if entry.commit and entry.commit.hash == target_sha then
        restore()
        -- panel.entries (checked above) updates synchronously per streamed
        -- commit, but the panel's rendered component tree -- which
        -- highlight_item() inside set_file() searches to place the cursor
        -- -- only rebuilds on a throttled render tick. Force a sync first
        -- so the component tree already contains our target and the
        -- cursor move in set_file() doesn't silently no-op.
        view.panel:sync()
        view:set_file(entry.files[1], false)
        return
      end
    end

    if attempts < 50 then
      vim.defer_fn(function() poll(attempts + 1) end, 100)
    else
      restore()
      vim.notify('Commit not found in file history', vim.log.levels.WARN)
      view:next_item()
    end
  end

  poll()
end
