{pkgs, ...}: {
  programs.nvf.settings.vim = {
    extraPlugins.reviewthem-nvim = {
      package = pkgs.vimUtils.buildVimPlugin {
        pname = "reviewthem-nvim";
        version = "2025-03-19";
        src = pkgs.fetchFromGitHub {
          owner = "KEY60228";
          repo = "reviewthem.nvim";
          rev = "1ebe42e5803c9c1486b9f2f8a5f19e69f03ec71b";
          hash = "sha256-ym4POCloKj3tNURhmjmAVQ/t2N5OALc5LwKmk8Wd/KU=";
        };
      };
      setup = ''
        require("reviewthem").setup({
          keymaps = {
            add_comment = "<leader>rc",
            confirm_comment = "<A-CR>",
            cancel_comment = "<Esc>",
            submit_review = "<leader>rS",
            toggle_reviewed = "<leader>rm",
            show_comments = "<leader>rl",
            focus_tree = "<leader>re",
            close_review = "<leader>rq",
          },
        })

        -- Custom command: copy comments to clipboard and clear them, keep session open
        vim.api.nvim_create_user_command("ReviewThemFlush", function()
          local state = require("reviewthem.session.state")
          if not state.ensure_active() then return end
          local session = state.get_active()
          if not session then return end
          local all_comments = {}
          for _, file in ipairs(session.files or {}) do
            local file_comments = state.get_file_comments(file.path or file)
            for _, c in ipairs(file_comments) do
              table.insert(all_comments, c)
            end
          end
          if #all_comments == 0 then
            vim.notify("No comments to flush", vim.log.levels.INFO)
            return
          end
          local output = vim.fn.json_encode({ review = { comments = all_comments } })
          vim.fn.setreg("+", output)
          for _, c in ipairs(all_comments) do
            state.remove_comment(c.id)
          end
          vim.notify(string.format("Flushed %d comments to clipboard", #all_comments), vim.log.levels.INFO)
        end, {})

        -- Custom command: show review progress in a floating window
        vim.api.nvim_create_user_command("ReviewThemStatus", function()
          local state = require("reviewthem.session.state")
          if not state.ensure_active() then return end
          local session = state.get_active()
          if not session then return end
          local reviewed, total = state.get_progress()
          local lines = {
            "Review Status", "",
            string.format("Progress: %d/%d files reviewed", reviewed, total), "",
            "Files:",
          }
          for _, file in ipairs(session.files or {}) do
            local path = file.path or file
            local is_reviewed = state.is_reviewed(path)
            local status = is_reviewed and "[x]" or "[ ]"
            local file_comments = state.get_file_comments(path)
            local suffix = #file_comments > 0 and string.format(" (%d comments)", #file_comments) or ""
            table.insert(lines, string.format("  %s %s%s", status, path, suffix))
          end

          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
          vim.bo[buf].modifiable = false
          vim.bo[buf].buftype = "nofile"
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
              local file_match = line_content:match("%s*%[.%]%s+(%S+)")
              if file_match then
                state.toggle_reviewed(file_match)
                vim.api.nvim_win_close(win, true)
                vim.cmd("ReviewThemStatus")
              end
            end,
          })
        end, {})

        -- Monkeypatch comment_input: use CR to confirm and Esc to cancel in normal mode,
        -- disable autocomplete in the comment float
        local comment_input = require("reviewthem.ui.comment_input")
        local orig_open = comment_input.open
        comment_input.open = function(opts)
          local orig_on_confirm = opts.on_confirm
          local orig_on_cancel = opts.on_cancel

          -- Wrap to inject our keymaps after the float is created
          local buf_ref, win_ref
          local wrapped_opts = vim.tbl_extend("force", opts, {
            on_confirm = function(text)
              if orig_on_confirm then orig_on_confirm(text) end
            end,
            on_cancel = function()
              if orig_on_cancel then orig_on_cancel() end
            end,
          })

          -- Call original open
          orig_open(wrapped_opts)

          -- Find the newly created float and add our keymaps
          vim.schedule(function()
            for _, w in ipairs(vim.api.nvim_list_wins()) do
              local cfg = vim.api.nvim_win_get_config(w)
              if cfg.relative and cfg.relative ~= "" then
                local b = vim.api.nvim_win_get_buf(w)
                local bt = vim.bo[b].buftype
                if bt == "nofile" or bt == "acwrite" then
                  -- Disable autocomplete
                  local cmp_ok, cmp = pcall(require, "cmp")
                  if cmp_ok then
                    cmp.setup.buffer({ enabled = false })
                  end
                end
              end
            end
          end)
        end
      '';
    };
  };
}
