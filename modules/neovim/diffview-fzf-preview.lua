local Previewer = require('fzf-lua.previewer.builtin').buffer_or_file

local function diff_entry(entry, cwd)
  local lib = package.loaded['diffview.lib']
  local view = lib and lib.get_current_view()
  if not view or not view.files then return end
  local path = entry.path or (entry.uri and vim.uri_to_fname(entry.uri))
  if not path then return end
  if not vim.startswith(path, '/') then path = (cwd or vim.fn.getcwd()) .. '/' .. path end
  path = vim.fn.resolve(vim.fs.normalize(path))
  for _, e in view.files:iter() do
    if vim.fn.resolve(e.adapter.ctx.toplevel .. '/' .. e.path) == path then return e end
  end
end

local preview_buf_post = Previewer.preview_buf_post

function Previewer:preview_buf_post(entry, min_winopts)
  preview_buf_post(self, entry, min_winopts)
  local bufnr = self.preview_bufnr
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= 'nofile' then return end
  diffview_mark_buffer(bufnr, diff_entry(entry, self.opts.cwd), self.win.preview_winid)
end

local update_title = Previewer.update_title

function Previewer:update_title(entry)
  local e = diff_entry(entry, self.opts.cwd)
  if not e or not self.win then return update_title(self, entry) end
  local own = rawget(self.win, 'update_preview_title')
  local base = self.win.update_preview_title
  self.win.update_preview_title = function(win, title)
    return base(win, ' [' .. e.status .. ']' .. title)
  end
  local ok, err = pcall(update_title, self, entry)
  self.win.update_preview_title = own
  if not ok then error(err) end
end
