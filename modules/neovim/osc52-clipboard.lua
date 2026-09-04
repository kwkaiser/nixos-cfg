-- Only override the clipboard provider when SSH'd in: locally, wl-copy/wl-paste
-- (auto-detected by nvim) is faster and supports paste, which Kitty's OSC 52
-- reads don't (write-only by default, so a remote "+p would hang and time out).
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  local osc52 = require("vim.ui.clipboard.osc52")

  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = osc52.paste("+"),
      ["*"] = osc52.paste("*"),
    },
  }
end
