function review_branch_against_main()
  local root = git_root_for_buf()
  require('fzf-lua').fzf_exec("git branch --sort=-committerdate --no-color | sed 's/^[* ]*//'", {
    prompt = 'Review against main> ',
    cwd = root,
    preview = 'git log --max-count=16 --graph --pretty=oneline --abbrev-commit --color {1}',
    actions = {
      ['default'] = function(selected)
        if not selected[1] then return end
        vim.cmd('DiffviewOpen main..' .. selected[1])
      end,
    },
  })
end
