do
  (function()
    local function warn(msg)
      vim.notify_once('diffview-fzf-preview: ' .. msg, vim.log.levels.WARN)
    end

    local ok_builtin, builtin = pcall(require, 'fzf-lua.previewer.builtin')
    local Previewer = ok_builtin and builtin.buffer_or_file
    local preview_buf_post = Previewer and Previewer.preview_buf_post
    local update_title = Previewer and Previewer.update_title
    if type(preview_buf_post) ~= 'function' or type(update_title) ~= 'function' then
      return warn('fzf-lua internals changed, diff info in previews disabled')
    end

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

    local function mark(self, entry)
      local bufnr = self.preview_bufnr
      if not diffview_mark_buffer or not bufnr or not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= 'nofile' then return end
      diffview_mark_buffer(bufnr, diff_entry(entry, self.opts.cwd), self.win.preview_winid)
    end

    function Previewer:preview_buf_post(entry, min_winopts)
      local result = preview_buf_post(self, entry, min_winopts)
      local ok, err = pcall(mark, self, entry)
      if not ok then warn(tostring(err)) end
      return result
    end

    function Previewer:update_title(entry)
      local ok, e = pcall(diff_entry, entry, self.opts.cwd)
      if not ok then warn(tostring(e)) end
      local win = self.win
      if not ok or not e or not win or type(win.update_preview_title) ~= 'function' then
        return update_title(self, entry)
      end
      local own = rawget(win, 'update_preview_title')
      local base = win.update_preview_title
      win.update_preview_title = function(w, title)
        return base(w, ' [' .. tostring(e.status) .. ']' .. title)
      end
      local ok_title, result = pcall(update_title, self, entry)
      win.update_preview_title = own
      if not ok_title then error(result, 0) end
      return result
    end
  end)()
end
