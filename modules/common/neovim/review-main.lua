function review_branch_against_main()
  local root = git_root_for_buf()
  require('fzf-lua').git_branches({
    prompt = 'Review against main> ',
    cwd = root,
    cmd = 'git branch --sort=-committerdate --no-color',
    actions = {
      ['default'] = function(selected)
        local branch = selected[1]:gsub('^[%s%*%+]+', ''):match('([^%s]+)')
        vim.cmd('DiffviewOpen main..' .. branch)
      end,
    },
  })
end
