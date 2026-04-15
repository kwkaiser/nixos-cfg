{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./ts.nix
    ./review.nix
  ];

  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [
    ripgrep
    fd
    fzf
    tree-sitter
  ];

  # Shell wrapper: opens neovim with git-based socket name for external RPC
  programs.zsh.initContent = ''
    nvim() {
      if git rev-parse --show-toplevel &>/dev/null; then
        local repo_name=$(basename "$(git rev-parse --show-toplevel)")
        local socket_path="/tmp/nvim-''${repo_name}.sock"

        # Clean up stale socket if it exists but no process is listening
        if [[ -S "$socket_path" ]] && ! command nvim --server "$socket_path" --remote-expr "1" &>/dev/null; then
          rm -f "$socket_path"
        fi

        command nvim --listen "$socket_path" --cmd "cd $(git rev-parse --show-toplevel)" "$@"
      else
        command nvim "$@"
      fi
    }
    vim() { nvim "$@"; }
  '';

  programs.neovim = {
    defaultEditor = true;
    vimAlias = false; # Handled via shell function above
  };

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        vimAlias = false; # Handled via shell function above
        globals.mapleader = " ";
        clipboard = {
          enable = true;
          registers = "unnamedplus";
        };
        options = {
          tabstop = 2;
          shiftwidth = 2;
          expandtab = true;
          timeoutlen = 10;
        };

        theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
        };

        lsp = {
          enable = true;

          mappings = {
            # Disabled - using fzf-lua alternatives
            codeAction = null;
            listReferences = null;

            # Disabled: different bindings
            openDiagnosticFloat = "<leader>ldf";

            # Disabled - not used
            listImplementations = null;
            previousDiagnostic = null;
            hover = null;
            renameSymbol = "<leader>lsr";
            nextDiagnostic = null;
            goToDeclaration = null;
            signatureHelp = null;
            addWorkspaceFolder = null;
            removeWorkspaceFolder = null;
            listWorkspaceFolders = null;
            listWorkspaceSymbols = null;
            documentHighlight = null;
            listDocumentSymbols = null;
            toggleFormatOnSave = "<leader>lf";
            format = null; # Using formatOnSave instead
          };
        };

        fzf-lua = {
          enable = true;
          setupOpts = {
            keymap = {
              fzf = {
                "ctrl-q" = "select-all+accept";
                "ctrl-a" = "select-all";
              };
            };
            git = {
              branches = {
                cmd = "git branch --color";
              };
            };
          };
        };

        binds.whichKey.enable = true;

        autocomplete.nvim-cmp = {
          enable = true;
          sources = {
            nvim_lsp = "[LSP]";
            path = "[Path]";
            buffer = lib.mkForce null;
            treesitter = lib.mkForce null;
          };
        };
        autopairs.nvim-autopairs.enable = true;
        statusline.lualine = {
          enable = true;
          setupOpts.tabline = {
            lualine_a = [
              (lib.generators.mkLuaInline ''
                {
                  'tabs',
                  mode = 1,
                  fmt = function(name, context)
                    return tab_format(name, context)
                  end,
                }
              '')
            ];
          };
          activeSection.b = [
            ''
              {
                "filetype",
                colored = true,
                icon_only = true,
                icon = { align = 'left' }
              }
            ''
            ''
              {
                "filename",
                path = 1,
                symbols = {modified = ' ', readonly = ' '},
                separator = {right = '''}
              }
            ''
          ];
        };

        lsp.formatOnSave = true;

        languages = {
          typst = {
            enable = true;
            format.enable = true;
            lsp.enable = true;
            treesitter.enable = true;
            extensions = {
              typst-preview-nvim.enable = true;
            };
          };
          markdown = {
            enable = true;
            lsp.enable = false; # marksman requires building dotnet from source
          };
          python.enable = true;
          yaml.enable = true;
          sql.enable = true;
          rust.enable = true;
          bash.enable = true;
          go.enable = true;

          nix = {
            enable = true;
            format.enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };
        };

        git = {
          neogit.enable = true;
          neogit.setupOpts = {
            signing = {
              enabled = true;
            };
            integrations = {
              diffview = true;
            };
          };
        };

        utility.diffview-nvim = {
          enable = true;
          setupOpts = {
            show_untracked = true;
            view = {
              merge_tool = {
                layout = "diff3_mixed";
              };
            };
            keymaps = {
              view = [
                ["n" "<leader>rc" "<Cmd>ReviewThemAddComment<CR>" {desc = "Add review comment";}]
                ["n" "<leader>rC" "<Cmd>ReviewThemFlush<CR>" {desc = "Copy comments to clipboard and clear";}]
                ["n" "q" "<Cmd>lua local ok, _ = pcall(vim.cmd, 'ReviewThemAbort'); if not ok then vim.cmd('DiffviewClose') end<CR>" {desc = "Close and discard review";}]
                ["n" "Q" "<Cmd>lua pcall(vim.cmd, 'ReviewThemSubmit'); vim.cmd('DiffviewClose')<CR>" {desc = "Close and copy review to clipboard";}]
                ["n" "R" "<Cmd>DiffviewRefresh<CR>" {desc = "Refresh diffview";}]
              ];
              file_panel = [
                ["n" "<leader>rc" "<Cmd>ReviewThemAddComment<CR>" {desc = "Add review comment";}]
                ["n" "<leader>rC" "<Cmd>ReviewThemFlush<CR>" {desc = "Copy comments to clipboard and clear";}]
                ["n" "q" "<Cmd>lua local ok, _ = pcall(vim.cmd, 'ReviewThemAbort'); if not ok then vim.cmd('DiffviewClose') end<CR>" {desc = "Close and discard review";}]
                ["n" "Q" "<Cmd>lua pcall(vim.cmd, 'ReviewThemSubmit'); vim.cmd('DiffviewClose')<CR>" {desc = "Close and copy review to clipboard";}]
                ["n" "R" "<Cmd>DiffviewRefresh<CR>" {desc = "Refresh diffview";}]
              ];
              file_history_panel = [
                ["n" "<leader>gc" "<Cmd>lua diff_commit_at_cursor()<CR>" {desc = "View full commit diff";}]
              ];
            };
          };
        };
        filetree.neo-tree = {
          enable = true;
          setupOpts = {
            filesystem = {
              use_libuv_file_watcher = false;
              scan_mode = "shallow";
              find_by_full_path_words = false;
              async_directory_scan = "always";
            };
            git_status_async = true;
            enable_git_status = true;
            enable_diagnostics = false;
          };
        };

        keymaps = [
          {
            key = "<C-s>";
            mode = [
              "n"
              "i"
            ];
            action = "<cmd>lua eslint_fix_all_sync()<CR><cmd>w<CR>";
            desc = "Save file";
          }

          # Files & buffers
          {
            key = "<leader>ff";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').files()<CR>";
            desc = "Find files";
          }
          {
            key = "<leader>fb";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').buffers()<CR>";
            desc = "Find buffers";
          }

          # Search
          {
            key = "<leader>fs";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').live_grep()<CR>";
            desc = "Live grep";
          }

          {
            key = "<leader>fqq";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').quickfix()<CR>";
            desc = "Open quickfix list";
          }

          {
            key = "<leader>fqc";
            mode = "n";
            action = "<cmd>lua vim.fn.setreg('+', table.concat(vim.tbl_map(function(e) return vim.fn.bufname(e.bufnr) .. ':' .. e.lnum .. ':' .. e.col .. ' ' .. e.text end, vim.fn.getqflist()), '\\n'))<CR>";
            desc = "Copy quickfix to clipboard";
          }

          # LSP
          {
            key = "<leader>la";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').lsp_code_actions({ silent = true })<CR>";
            desc = "Code actions";
          }
          {
            key = "<leader>lr";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').lsp_references()<CR>";
            desc = "Code references";
          }
          {
            key = "<leader>ldd";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').diagnostics_document()<CR>";
            desc = "Diagnostics (file)";
          }
          {
            key = "<leader>ldw";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').diagnostics_workspace()<CR>";
            desc = "Diagnostics (workspace)";
          }
          {
            key = "<leader>ldc";
            mode = "n";
            action = "<cmd>lua vim.fn.setreg('+', vim.diagnostic.get(0, {lnum = vim.fn.line('.') - 1})[1].message)<CR>";
            desc = "Copy diagnostic";
          }
          {
            key = "<leader>lt";
            mode = "n";
            action = "<cmd>lua vim.lsp.buf.hover()<CR>";
            desc = "Type description";
          }

          # Git
          {
            key = "<leader>gs";
            mode = "n";
            action = "<cmd>Neogit<CR>";
            desc = "Git status";
          }
          {
            key = "<leader>gh";
            mode = "n";
            action = "<cmd>lua open_file_history()<CR>";
            desc = "File history";
          }
          {
            key = "<leader>gL";
            mode = "n";
            action = "<cmd>lua copy_github_url()<CR>";
            desc = "Copy GitHub URL to clipboard";
          }
          {
            key = "<leader>gl";
            mode = ["n" "v"];
            action = "<cmd>lua copy_file_location()<CR>";
            desc = "Copy file:line to clipboard";
          }
          {
            key = "<leader>gdc";
            mode = "n";
            action = "<cmd>lua review_compare_branches()<CR>";
            desc = "Review compare branches";
          }
          {
            key = "<leader>gdm";
            mode = "n";
            action = "<cmd>lua review_branch_against_main()<CR>";
            desc = "Review branch against main";
          }
          {
            key = "<leader>gdd";
            mode = "n";
            action = "<cmd>lua diff_working_changes()<CR>";
            desc = "Diff working changes against branch";
          }
          {
            key = "<leader>b";
            mode = "n";
            action = "<cmd>:Neotree filesystem reveal float<CR>";
            desc = "Open filetree";
          }
          {
            key = "<leader>th";
            mode = "n";
            action = "<cmd>lua open_terminal_horizontal()<CR>";
            desc = "Terminal horizontal";
          }
          {
            key = "<leader>tv";
            mode = "n";
            action = "<cmd>lua open_terminal_vertical()<CR>";
            desc = "Terminal vertical";
          }
          {
            key = "<Esc><Esc>";
            mode = "t";
            action = "<C-\\><C-n>";
            desc = "Exit terminal mode";
          }
        ];

        luaConfigRC.gitRoot = builtins.readFile ./git-root.lua;
        luaConfigRC.tab-format = builtins.readFile ./tab-format.lua;
        luaConfigRC.file-history = builtins.readFile ./file-history.lua;
        luaConfigRC.review-compare = builtins.readFile ./review-compare.lua;
        luaConfigRC.review-main = builtins.readFile ./review-main.lua;
        luaConfigRC.diff-status = builtins.readFile ./diff-status.lua;
        luaConfigRC.diff-commit = builtins.readFile ./diff-commit.lua;
        luaConfigRC.github-url = builtins.readFile ./github-url.lua;
        luaConfigRC.file-location = builtins.readFile ./file-location.lua;
      };
    };
  };
}
