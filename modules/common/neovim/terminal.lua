local function get_terminal_dir()
  local file_dir = vim.fn.expand('%:p:h')
  if file_dir == "" or file_dir == "." then
    file_dir = vim.fn.getcwd()
  end
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(file_dir) .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error == 0 and git_root and git_root ~= "" then
    return git_root
  else
    return file_dir
  end
end

_G.open_terminal_horizontal = function()
  local dir = get_terminal_dir()
  vim.cmd('lcd ' .. vim.fn.fnameescape(dir))
  vim.cmd('split')
  vim.cmd('terminal')
end

_G.open_terminal_vertical = function()
  local dir = get_terminal_dir()
  vim.cmd('lcd ' .. vim.fn.fnameescape(dir))
  vim.cmd('vsplit')
  vim.cmd('terminal')
end
