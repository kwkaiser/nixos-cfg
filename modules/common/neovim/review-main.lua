function review_branch_against_main()
  require('fzf-lua').git_branches({
    prompt = 'Review against main> ',
    cmd = 'git branch --sort=-committerdate --no-color',
    actions = {
      ['default'] = function(selected)
        local branch = selected[1]:gsub('^[%s%*%+]+', ''):match('([^%s]+)')
        vim.cmd('ReviewThemStart main ' .. branch)
      end,
    },
  })
end
