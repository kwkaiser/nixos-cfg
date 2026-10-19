local GitAdapter = require('diffview.vcs.adapters.git').GitAdapter
local RevType = require('diffview.vcs.rev').RevType
local show_untracked = GitAdapter.show_untracked

GitAdapter.show_untracked = function(self, opt)
  if opt and opt.revs and opt.revs.right.type == RevType.LOCAL then
    opt = { dv_opt = opt.dv_opt }
  end
  return show_untracked(self, opt)
end
