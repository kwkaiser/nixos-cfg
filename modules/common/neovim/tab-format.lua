function tab_format(name, context)
  for _, bufnr in ipairs(vim.fn.tabpagebuflist(context.tabnr)) do
    local ft = vim.bo[bufnr].filetype
    if ft == 'DiffviewFileHistory' then
      return 'Diff View History'
    elseif ft:match('^Diffview') then
      return 'Diff View'
    end
  end
  return name
end
