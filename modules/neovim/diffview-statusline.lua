local diffview_statusline_saved

vim.api.nvim_create_autocmd("User", {
  pattern = "DiffviewViewEnter",
  callback = function()
    if diffview_statusline_saved then return end
    pcall(function() require("lualine").hide({ place = { "statusline" } }) end)
    diffview_statusline_saved = { laststatus = vim.o.laststatus, statusline = vim.go.statusline }
    vim.o.laststatus = 0
    vim.go.statusline = " "
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "DiffviewViewLeave",
  callback = function()
    if not diffview_statusline_saved then return end
    vim.o.laststatus = diffview_statusline_saved.laststatus
    vim.go.statusline = diffview_statusline_saved.statusline
    diffview_statusline_saved = nil
    pcall(function() require("lualine").hide({ place = { "statusline" }, unhide = true }) end)
  end,
})
