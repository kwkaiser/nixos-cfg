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

    FileEntry.with_layout = function(layout_class, opt)
      local ok, swap = pcall(is_diff2, layout_class)
      if not ok then warn('layout check failed: ' .. tostring(swap)) end
      return with_layout(ok and swap and Diff1 or layout_class, opt)
    end

    function diffview_toggle_layout()
      local ok, err = pcall(function()
        local view = require('diffview.lib').get_current_view()
        if not view then return end
        local entry = view.cur_entry or (view.cur_file and view:cur_file())
        if not entry or entry.kind == 'conflicting' then return end

        if entry.layout:instanceof(Diff1) then
          entry:convert_layout(view.get_default_layout())
        else
          entry:convert_layout(Diff1)
        end

        local was_focused = view.cur_layout:is_focused()
        view:set_file(entry, false)
        if was_focused then view.cur_layout:get_main_win():focus() end
      end)
      if not ok then warn('layout toggle failed: ' .. tostring(err)) end
    end
  end)()
end
