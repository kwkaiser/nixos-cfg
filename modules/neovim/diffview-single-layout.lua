local FileEntry = require('diffview.scene.file_entry').FileEntry
local Diff1 = require('diffview.scene.layouts.diff_1').Diff1
local Diff2 = require('diffview.scene.layouts.diff_2').Diff2
local with_layout = FileEntry.with_layout

local function is_diff2(layout_class)
  local cur = layout_class
  while cur do
    if cur == Diff2 then return true end
    cur = cur.super_class
  end
  return false
end

FileEntry.with_layout = function(layout_class, opt)
  if is_diff2(layout_class) then
    layout_class = Diff1
  end
  return with_layout(layout_class, opt)
end

function diffview_toggle_layout()
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
end
