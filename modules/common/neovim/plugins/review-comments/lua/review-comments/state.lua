local M = {}

---@class ReviewComment
---@field file string
---@field line_start integer
---@field line_end integer
---@field side "old"|"new"
---@field comment string
---@field bufnr integer

---@type ReviewComment[]
local comments = {}

local sign_group = "review_comments"
local sign_name = "ReviewComment"
local sign_defined = false

local function ensure_sign()
  if not sign_defined then
    vim.fn.sign_define(sign_name, { text = "💬", texthl = "DiagnosticInfo" })
    sign_defined = true
  end
end

--- Place signs for a comment on its buffer
---@param comment ReviewComment
local function place_signs(comment)
  ensure_sign()
  if not vim.api.nvim_buf_is_valid(comment.bufnr) then return end
  for line = comment.line_start, comment.line_end do
    vim.fn.sign_place(0, sign_group, sign_name, comment.bufnr, { lnum = line })
  end
end

--- Add a comment and place signs
---@param comment ReviewComment
function M.add(comment)
  table.insert(comments, comment)
  place_signs(comment)
end

--- Get all comments
---@return ReviewComment[]
function M.get_all()
  return comments
end

--- Check if there are no comments
---@return boolean
function M.is_empty()
  return #comments == 0
end

--- Clear all comments and remove all signs
function M.clear()
  vim.fn.sign_unplace(sign_group)
  comments = {}
end

return M
