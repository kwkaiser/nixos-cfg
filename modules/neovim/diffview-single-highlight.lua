do
  (function()
    local function warn(msg)
      vim.notify_once('diffview-single-highlight: ' .. msg, vim.log.levels.WARN)
    end

    local function safe(fn)
      return function(...)
        local ok, err = pcall(fn, ...)
        if not ok then warn(tostring(err)) end
      end
    end

    local ns = vim.api.nvim_create_namespace('diffview_single_highlight')
    local group = vim.api.nvim_create_augroup('diffview_single_highlight', { clear = true })
    local decorated = {}
    local enabled = true

    local function current_view()
      local lib = package.loaded['diffview.lib']
      if not lib then return end
      local ok, view = pcall(lib.get_current_view)
      return ok and view or nil
    end

    local function clear_all()
      for bufnr in pairs(decorated) do
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
          vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
        end
      end
      decorated = {}
    end

    local function old_lines(entry)
      if entry.status == 'A' or entry.status == '?' then return {} end
      local rev = entry.revs.a
      local path = entry.oldpath or entry.path
      local root = entry.adapter.ctx.toplevel
      if rev.type == require('diffview.vcs.rev').RevType.LOCAL then
        local ok, lines = pcall(vim.fn.readfile, root .. '/' .. path)
        return ok and lines or {}
      end
      local out = vim.fn.systemlist({ 'git', '-C', root, 'show', rev:object_name() .. ':' .. path })
      if vim.v.shell_error ~= 0 then return {} end
      return out
    end

    local function render(bufnr, old, winid)
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      local new = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local old_text = #old > 0 and table.concat(old, '\n') .. '\n' or ''
      local new_text = #new > 0 and table.concat(new, '\n') .. '\n' or ''
      if new_text == '\n' then new_text = '' end
      local hunks = vim.text.diff(old_text, new_text, { result_type = 'indices' })
      local width = vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_width(winid) or 200

      for _, h in ipairs(hunks) do
        local start_a, count_a, start_b, count_b = h[1], h[2], h[3], h[4]

        for row = start_b - 1, start_b + count_b - 2 do
          vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, { line_hl_group = 'DiffAdd' })
        end

        if count_a > 0 then
          local virt = {}
          for i = start_a, start_a + count_a - 1 do
            local text = old[i]:gsub('\t', string.rep(' ', vim.bo[bufnr].tabstop))
            virt[#virt + 1] = { { text .. string.rep(' ', math.max(0, width - vim.fn.strdisplaywidth(text))), 'DiffDelete' } }
          end
          local above = count_b > 0 or start_b == 0
          local row = count_b > 0 and start_b - 1 or math.max(start_b - 1, 0)
          vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, { virt_lines = virt, virt_lines_above = above })
        end
      end
    end

    diffview_mark_buffer = safe(function(bufnr, entry, winid)
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      if enabled and entry then render(bufnr, old_lines(entry), winid) end
    end)

    local function decorate()
      local view = current_view()
      if not view or not view.cur_layout then return end
      clear_all()

      local Diff1 = require('diffview.scene.layouts.diff_1').Diff1
      if not view.cur_layout:instanceof(Diff1) then
        for _, w in ipairs(view.cur_layout.windows) do
          if w.id and vim.api.nvim_win_is_valid(w.id) then
            vim.wo[w.id].diff = enabled
            vim.wo[w.id].foldenable = enabled
          end
        end
        return
      end
      if not enabled then return end

      local entry = view.cur_entry
      local win = view.cur_layout.b
      local bufnr = win and win.file and win.file.bufnr
      if not entry or not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return end

      local old = old_lines(entry)
      decorated[bufnr] = true
      render(bufnr, old, win.id)
      vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
        group = group,
        buffer = bufnr,
        callback = safe(function() render(bufnr, old, win.id) end),
      })
    end

    diffview_purge_hidden_diff_bufs = safe(function()
      local shown = {}
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        shown[vim.api.nvim_win_get_buf(win)] = true
      end
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if not shown[bufnr] and vim.api.nvim_buf_is_loaded(bufnr) then
          vim.api.nvim_buf_call(bufnr, function() vim.wo.diff = false end)
        end
      end
    end)

    diffview_toggle_highlight = safe(function()
      enabled = not enabled
      decorate()
    end)

    vim.api.nvim_create_autocmd('User', {
      group = vim.api.nvim_create_augroup('diffview_single_highlight_events', { clear = true }),
      pattern = { 'DiffviewDiffBufWinEnter', 'DiffviewViewLeave', 'DiffviewViewClosed' },
      callback = safe(function(ev)
        if ev.match == 'DiffviewDiffBufWinEnter' then
          diffview_purge_hidden_diff_bufs()
          decorate()
        else
          clear_all()
        end
      end),
    })

    local strip_foreign_diff = safe(function()
      local view = current_view()
      if not view or not view.cur_layout then return end
      local owned = {}
      for _, w in ipairs(view.cur_layout.windows) do
        if w.id then owned[w.id] = true end
      end
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if not owned[win] and vim.wo[win].diff then
          vim.wo[win].diff = false
          vim.wo[win].scrollbind = false
          vim.wo[win].cursorbind = false
          vim.wo[win].foldenable = false
        end
      end
    end)

    local strip_group = vim.api.nvim_create_augroup('diffview_strip_foreign_diff', { clear = true })

    vim.api.nvim_create_autocmd({ 'WinNew', 'WinEnter', 'BufWinEnter' }, {
      group = strip_group,
      callback = function() strip_foreign_diff() end,
    })

    vim.api.nvim_create_autocmd('WinClosed', {
      group = strip_group,
      callback = function()
        vim.schedule(function()
          if current_view() then diffview_purge_hidden_diff_bufs() end
        end)
      end,
    })

    local open_win = vim.api.nvim_open_win
    vim.api.nvim_open_win = function(...)
      local win = open_win(...)
      if current_view() then strip_foreign_diff() end
      return win
    end
  end)()
end
