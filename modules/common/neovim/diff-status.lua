function diff_working_changes()
  require('fzf-lua').git_branches({
    prompt = 'Base branch> ',
    cmd = 'git branch --sort=-committerdate --no-color',
    actions = {
      ['default'] = function(selected)
        local base = selected[1]:gsub('^[%s%*%+]+', ''):match('([^%s]+)')
        vim.cmd('DiffviewOpen ' .. base)
      end,
    },
  })
end
