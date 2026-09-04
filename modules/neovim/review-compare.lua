function review_compare_branches()
  local root = git_root_for_buf()
  local cmd = "git branch --sort=-committerdate --no-color | sed 's/^[* +]*//'"
  local preview = 'git log --max-count=16 --graph --pretty=oneline --abbrev-commit --color {1}'
  require('fzf-lua').fzf_exec(cmd, {
    prompt = 'Base branch> ',
    cwd = root,
    preview = preview,
    actions = {
      ['default'] = function(selected)
        if not selected[1] then return end
        local base = selected[1]
        require('fzf-lua').fzf_exec(cmd, {
          prompt = 'Compare branch> ',
          cwd = root,
          preview = preview,
          actions = {
            ['default'] = function(selected2)
              if not selected2[1] then return end
              vim.cmd('DiffviewOpen ' .. base .. '..' .. selected2[1])
            end,
          },
        })
      end,
    },
  })
end
