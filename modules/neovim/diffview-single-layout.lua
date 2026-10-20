do
  (function()
    local function warn(msg)
      vim.notify_once('diffview-single-layout: ' .. msg, vim.log.levels.WARN)
    end

    local ok_entry, file_entry = pcall(require, 'diffview.scene.file_entry')
    local ok_d1, diff_1 = pcall(require, 'diffview.scene.layouts.diff_1')
    local ok_d2, diff_2 = pcall(require, 'diffview.scene.layouts.diff_2')
    local FileEntry = ok_entry and file_entry.FileEntry
    local Diff1 = ok_d1 and diff_1.Diff1
    local Diff2 = ok_d2 and diff_2.Diff2
    local with_layout = FileEntry and FileEntry.with_layout
    if type(with_layout) ~= 'function' or not Diff1 or not Diff2 then
      function diffview_toggle_layout() warn('disabled, diffview internals changed') end
      return warn('diffview internals changed, single-pane layout disabled')
    end

    local function is_diff2(layout_class)
      local cur = layout_class
      while cur do
        if cur == Diff2 then return true end
        cur = cur.super_class
      end
      return false
    end

    local single = true

    FileEntry.with_layout = function(layout_class, opt)
      if not single then return with_layout(layout_class, opt) end
      local ok, swap = pcall(is_diff2, layout_class)
      if not ok then warn('layout check failed: ' .. tostring(swap)) end
      return with_layout(ok and swap and Diff1 or layout_class, opt)
    end

    local function view_entries(view)
      local entries = {}
      if view.files and view.files.iter then
        for _, f in view.files:iter() do table.insert(entries, f) end
      elseif view.panel and view.panel.entries then
        for _, log in ipairs(view.panel.entries) do
          for _, f in ipairs(log.files or {}) do table.insert(entries, f) end
        end
      end
      return entries
    end

    local function apply_layout(view)
      local target = single and Diff1 or view.get_default_layout()
      for _, f in ipairs(view_entries(view)) do
        if f.kind ~= 'conflicting' and f.layout and is_diff2(f.layout.class) ~= is_diff2(target) then
          f:convert_layout(target)
        end
      end
    end

    function diffview_toggle_layout()
      local ok, err = pcall(function()
        local view = require('diffview.lib').get_current_view()
        if not view then return end
        single = not single
        for _, v in ipairs(require('diffview.lib').views) do
          if v ~= view then pcall(apply_layout, v) end
        end
        apply_layout(view)

        local entry = view.cur_entry or (view.cur_file and view:cur_file())
        if not entry or entry.kind == 'conflicting' then return end

        local main = view.cur_layout:get_main_win()
        local cursor = main and main.id and vim.api.nvim_win_is_valid(main.id) and vim.api.nvim_win_get_cursor(main.id)
        if cursor then
          view.emitter:once('file_open_post', function()
            vim.schedule(function()
              local w = view.cur_layout:get_main_win()
              if not w or not w.id or not vim.api.nvim_win_is_valid(w.id) then return end
              local last = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(w.id))
              pcall(vim.api.nvim_win_set_cursor, w.id, { math.min(cursor[1], last), cursor[2] })
              vim.api.nvim_win_call(w.id, function() vim.cmd('normal! zvzz') end)
            end)
          end)
        end

        local was_focused = view.cur_layout:is_focused()
        view:set_file(entry, false)
        if was_focused then view.cur_layout:get_main_win():focus() end
      end)
      if not ok then warn('layout toggle failed: ' .. tostring(err)) end
    end
  end)()
end
