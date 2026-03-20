function diff_commit_at_cursor()
  local ok, lib = pcall(require, 'diffview.lib')
  if not ok then return end

  local view = lib.get_current_view()
  if not view or not view.panel then return end

  local item = view.panel:get_item_at_cursor()
  if not item or not item.commit then return end

  local hash = item.commit.hash
  vim.cmd('DiffviewOpen ' .. hash .. '^..' .. hash)
end
