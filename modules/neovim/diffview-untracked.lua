do
  (function()
    local function warn(msg)
      vim.notify_once('diffview-untracked: ' .. msg, vim.log.levels.WARN)
    end

    local ok_git, git = pcall(require, 'diffview.vcs.adapters.git')
    local ok_rev, rev = pcall(require, 'diffview.vcs.rev')
    local GitAdapter = ok_git and git.GitAdapter
    local RevType = ok_rev and rev.RevType
    local show_untracked = GitAdapter and GitAdapter.show_untracked
    if type(show_untracked) ~= 'function' or not RevType then
      return warn('diffview internals changed, untracked files are only shown against the index')
    end

    GitAdapter.show_untracked = function(self, opt)
      local ok, right_local = pcall(function() return opt.revs.right.type == RevType.LOCAL end)
      if ok and right_local then
        opt = { dv_opt = opt.dv_opt }
      end
      return show_untracked(self, opt)
    end
  end)()
end
