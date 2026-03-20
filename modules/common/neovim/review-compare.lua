function review_compare_branches()
  local root = git_root_for_buf()
  require('fzf-lua').git_branches({
    prompt = 'Base branch> ',
    cwd = root,
    cmd = 'git branch --sort=-committerdate --no-color',
    actions = {
      ['default'] = function(selected)
        local base = selected[1]:gsub('^[%s%*%+]+', ''):match('([^%s]+)')
        require('fzf-lua').git_branches({
          prompt = 'Compare branch> ',
          cwd = root,
          cmd = 'git branch --sort=-committerdate --no-color',
          actions = {
            ['default'] = function(selected2)
              local compare = selected2[1]:gsub('^[%s%*%+]+', ''):match('([^%s]+)')
              vim.cmd('ReviewThemStart ' .. base .. ' ' .. compare)
            end,
          },
        })
      end,
    },
  })
end
