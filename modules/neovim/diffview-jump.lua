local function layout_win(view, winid)
  for _, w in ipairs(view.cur_layout.windows) do
    if w.id == winid then return w end
  end
end

local function view_for_tab(tab)
  local lib = package.loaded['diffview.lib']
  if not lib then return end
  for _, view in ipairs(lib.views) do
    if view.tabpage == tab then return view end
  end
end

local set_buf = vim.api.nvim_win_set_buf

vim.api.nvim_win_set_buf = function(win, buf)
  local winid = win == 0 and vim.api.nvim_get_current_win() or win
  local view = vim.api.nvim_win_is_valid(winid) and view_for_tab(vim.api.nvim_win_get_tabpage(winid))
  if view and view.cur_layout then
    local lw = layout_win(view, winid)
    local foreign = lw and lw.file and buf ~= lw.file.bufnr and not vim.api.nvim_buf_get_name(buf):match('^diffview://null')
    if not foreign then
      return vim.cmd(('keepjumps call nvim_win_set_buf(%d, %d)'):format(winid, buf))
    end
  end
  return set_buf(win, buf)
end

local function find_entry(view, bufnr)
  if not view.files then return end
  local name = vim.fn.resolve(vim.api.nvim_buf_get_name(bufnr))
  for _, entry in view.files:iter() do
    for _, sym in ipairs({ 'b', 'a', 'c', 'd' }) do
      local w = entry.layout[sym]
      if w and w.file and w.file.bufnr == bufnr then return entry, sym end
    end
  end
  for _, entry in view.files:iter() do
    if vim.fn.resolve(entry.adapter.ctx.toplevel .. '/' .. entry.path) == name then return entry, 'b' end
  end
end

local function place(view, sym, cursor)
  local w = view.cur_layout[sym] or view.cur_layout:get_main_win()
  if not w or not w.id or not vim.api.nvim_win_is_valid(w.id) then return end
  vim.api.nvim_set_current_win(w.id)
  local last = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(w.id))
  pcall(vim.api.nvim_win_set_cursor, w.id, { math.min(cursor[1], last), cursor[2] })
  vim.cmd('normal! zv')
end

local function open_outside(target, cursor)
  local tab = require('diffview.lib').get_prev_non_view_tabpage()
  if tab then
    vim.api.nvim_set_current_tabpage(tab)
  else
    vim.cmd('tabnew')
  end
  local win = vim.api.nvim_get_current_win()
  local scratch = vim.api.nvim_win_get_buf(win)
  vim.cmd("normal! m'")
  vim.api.nvim_win_set_buf(win, target)
  pcall(vim.api.nvim_win_set_cursor, win, cursor)
  vim.cmd('normal! zv')
  if not tab and scratch ~= target and vim.api.nvim_buf_get_name(scratch) == '' and not vim.bo[scratch].modified then
    pcall(vim.api.nvim_buf_delete, scratch, {})
  end
end

local function redirect(view, winid, target, own)
  if not vim.api.nvim_win_is_valid(winid) or vim.api.nvim_win_get_buf(winid) ~= target then return end
  if not vim.api.nvim_buf_is_valid(own) then return end

  local cursor = vim.api.nvim_win_get_cursor(winid)
  vim.api.nvim_win_set_buf(winid, own)
  diffview_purge_hidden_diff_bufs()

  local entry, sym = find_entry(view, target)
  if not entry then
    if not vim.api.nvim_buf_get_name(target):match('^diffview://') then open_outside(target, cursor) end
    return
  end

  if entry == view.cur_entry then
    place(view, sym, cursor)
  else
    view.emitter:once(entry.opened and 'file_open_post' or 'file_open_new', function()
      vim.schedule(function() place(view, sym, cursor) end)
    end)
    view:set_file(entry, false, true)
  end
end

local function jump(direction)
  local view = require('diffview.lib').get_current_view()
  if not view then return end
  local list, pos = unpack(vim.fn.getjumplist())
  local current = vim.api.nvim_get_current_buf()
  local line = vim.fn.line('.')
  local n = 1
  while true do
    local item = list[pos + 1 + direction * n]
    if not item then return end
    local bufnr = item.bufnr
    if vim.api.nvim_buf_is_valid(bufnr) then
      if bufnr == current and item.lnum ~= line then break end
      if bufnr ~= current and find_entry(view, bufnr) then break end
    end
    n = n + 1
  end
  vim.cmd.normal({ args = { n .. vim.keycode(direction < 0 and '<C-o>' or '<C-i>') }, bang = true })
end

function diffview_jump_older() jump(-1) end
function diffview_jump_newer() jump(1) end

vim.api.nvim_create_autocmd('BufWinEnter', {
  group = vim.api.nvim_create_augroup('diffview_jump', { clear = true }),
  callback = function(ev)
    local view = require('diffview.lib').get_current_view()
    if not view or not view.cur_layout then return end
    local winid = vim.api.nvim_get_current_win()
    local win = layout_win(view, winid)
    if not win or not win.file or not win.file.bufnr then return end
    local own = win.file.bufnr
    if ev.buf == own or vim.api.nvim_buf_get_name(ev.buf):match('^diffview://null') then return end
    vim.schedule(function() redirect(view, winid, ev.buf, own) end)
  end,
})
