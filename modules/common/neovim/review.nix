{pkgs, ...}: {
  programs.nvf.settings.vim = {
    extraPlugins.reviewthem-nvim = {
      package = pkgs.vimUtils.buildVimPlugin {
        pname = "reviewthem-nvim";
        version = "2025-03-19";
        src = pkgs.fetchFromGitHub {
          owner = "KEY60228";
          repo = "reviewthem.nvim";
          rev = "main";
          hash = "sha256-ILv64yT4BcnYcnA9miilyEARBpDxFIWXt41LZMCB1Qk=";
        };
      };
      setup = ''
        require("reviewthem").setup({
          diff_tool = "diffview",
          submit_format = "json",
          submit_destination = "clipboard",
          keymaps = {
            start_review = "<Plug>(reviewthem-noop-start)",
            confirm_comment = "<Plug>(reviewthem-noop-confirm)",
            cancel_comment = "<Plug>(reviewthem-noop-cancel)",
            add_comment = "<Plug>(reviewthem-noop-add)",
            submit_review = "<Plug>(reviewthem-noop-submit)",
            abort_review = "<Plug>(reviewthem-noop-abort)",
            show_comments = "<leader>rl",
            toggle_reviewed = "<leader>rm",
            show_status = "<leader>rs",
          },
        })

        -- Custom command: copy comments to clipboard and clear them, keep session open
        vim.api.nvim_create_user_command("ReviewThemFlush", function()
          local state = require("reviewthem.state")
          local config = require("reviewthem.config")
          if not state.ensure_review_active() then return end
          local structured = state.get_all_comments_structured()
          if #structured.review.comments == 0 then
            vim.notify("No comments to flush", vim.log.levels.INFO)
            return
          end
          local opts = config.get()
          local output = opts.submit_format == "json" and vim.fn.json_encode(structured) or require("reviewthem.commands.review").format_as_markdown(structured)
          vim.fn.setreg("+", output)
          state.clear_comments()
          vim.fn.sign_unplace("reviewthem")
          vim.notify(string.format("Flushed %d comments to clipboard", #structured.review.comments), vim.log.levels.INFO)
        end, {})

        -- Monkeypatch: fix builtin UI bugs and add q to close modals
        local builtin = require("reviewthem.ui.builtin")

        local orig_show_comments = builtin.show_comments
        builtin.show_comments = function()
          orig_show_comments()
          -- Find the float buffer that was just created and add q keymap
          local wins = vim.api.nvim_list_wins()
          for _, w in ipairs(wins) do
            local cfg = vim.api.nvim_win_get_config(w)
            if cfg.relative and cfg.relative ~= "" then
              local b = vim.api.nvim_win_get_buf(w)
              pcall(vim.api.nvim_buf_set_keymap, b, "n", "q", ":close<CR>", { noremap = true, silent = true })
            end
          end
        end

        local orig_show_status = builtin.show_status
        builtin.show_status = function()
          local state = require("reviewthem.state")
          local base, compare = state.get_review_branches()
          local lines = {
            "Review Status", "",
            string.format("Base: %s", base),
            string.format("Compare: %s", compare or "Working Directory"), "",
          }
          local files = state.get_diff_files()
          if #files == 0 then
            vim.notify("No files in the current review session.", vim.log.levels.INFO)
            return
          end
          local reviewed_count = 0
          table.insert(lines, "Files:")
          for _, file in ipairs(files) do
            local reviewed = state.is_file_reviewed(file)
            if reviewed then reviewed_count = reviewed_count + 1 end
            local status = reviewed and "[x]" or "[ ]"
            table.insert(lines, string.format("  %s %s", status, file))
          end
          table.insert(lines, "")
          table.insert(lines, string.format("Progress: %d/%d files reviewed", reviewed_count, #files))
          local all_comments = state.get_comments()
          local comment_count = 0
          for _, fc in pairs(all_comments) do comment_count = comment_count + #fc end
          table.insert(lines, string.format("Total comments: %d", comment_count))
          table.insert(lines, "")
          table.insert(lines, "Press 't' to toggle reviewed status, 'q' to close")

          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
          vim.api.nvim_buf_set_option(buf, "modifiable", false)
          vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
          local width = math.min(60, vim.o.columns - 10)
          local height = math.min(#lines + 2, vim.o.lines - 10)
          local win = vim.api.nvim_open_win(buf, true, {
            relative = "editor", width = width, height = height,
            col = (vim.o.columns - width) / 2, row = (vim.o.lines - height) / 2,
            style = "minimal", border = "rounded",
            title = " Review Status ", title_pos = "center",
          })
          vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(buf, "n", "t", "", {
            noremap = true, silent = true,
            callback = function()
              local line = vim.api.nvim_win_get_cursor(win)[1]
              local line_content = vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1]
              local file = line_content:match("%s*%[.%]%s+(.+)")
              if file then
                if state.is_file_reviewed(file) then
                  state.unmark_file_reviewed(file)
                else
                  state.mark_file_reviewed(file)
                end
                vim.api.nvim_win_close(win, true)
                builtin.show_status()
              end
            end,
          })
        end

        -- Monkeypatch: per-mode keymaps for the comment float
        -- insert: Esc exits to normal mode (default vim), CR inserts newline (default vim)
        -- normal: Esc cancels comment, CR confirms comment
        local float_input = require("reviewthem.float_input")
        local orig_open = float_input.open
        float_input.open = function(opts)
          local buf, win = orig_open(opts)
          if buf and vim.api.nvim_buf_is_valid(buf) then
            local function safe_close()
              if win and vim.api.nvim_win_is_valid(win) then
                pcall(vim.api.nvim_win_close, win, true)
              end
              if buf and vim.api.nvim_buf_is_valid(buf) then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
              end
            end

            -- Find input area by locating the "── Comment ──" separator
            local all_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local input_start_line = 1
            for i, line in ipairs(all_lines) do
              if line:match("Comment") and line:match("──") then
                input_start_line = i + 1
                break
              end
            end
            local on_confirm = opts.on_confirm
            local on_cancel = opts.on_cancel

            -- Prevent backspace from deleting into the preview area
            vim.api.nvim_buf_set_keymap(buf, "i", "<BS>", "", {
              noremap = true, silent = true,
              callback = function()
                local cursor = vim.api.nvim_win_get_cursor(win)
                local row, col = cursor[1], cursor[2]
                if row <= input_start_line and col == 0 then
                  return -- Do nothing at the start of input area
                end
                -- Otherwise, perform normal backspace
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<BS>", true, false, true), "n", false)
              end,
            })

            vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
              noremap = true, silent = true,
              callback = function()
                local ok, lines = pcall(vim.api.nvim_buf_get_lines, buf, input_start_line - 1, -1, false)
                if not ok then
                  safe_close()
                  if on_cancel then on_cancel() end
                  return
                end
                while #lines > 0 and lines[#lines] == "" do
                  table.remove(lines)
                end
                local text = table.concat(lines, "\n")
                safe_close()
                if text ~= "" and on_confirm then
                  on_confirm(text)
                elseif on_cancel then
                  on_cancel()
                end
              end,
            })

            vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
              noremap = true, silent = true,
              callback = function()
                safe_close()
                if on_cancel then on_cancel() end
              end,
            })
          end
          return buf, win
        end
      '';
    };
  };
}
