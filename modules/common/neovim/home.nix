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

        command nvim --listen "$socket_path" "$@"
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
          markdown.enable = true;
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
            view = {
              merge_tool = {
                layout = "diff3_mixed";
              };
            };
            keymaps = {
              view = [
                ["n" "q" "<Cmd>DiffviewClose<CR>" {desc = "Close diffview";}]
                ["n" "R" "<Cmd>DiffviewRefresh<CR>" {desc = "Refresh diffview";}]
              ];
              file_panel = [
                ["n" "q" "<Cmd>DiffviewClose<CR>" {desc = "Close diffview";}]
                ["n" "R" "<Cmd>DiffviewRefresh<CR>" {desc = "Refresh diffview";}]
              ];
            };
          };
        };
        filetree.neo-tree.enable = true;

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
            key = "<leader>fq";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').quickfix()<CR>";
            desc = "Open quickfix list";
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
            key = "<leader>g";
            mode = "n";
            action = "<cmd>Neogit<CR>";
            desc = "Open git";
          }
          {
            key = "<leader>gdc";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').git_branches({ prompt = 'Base branch> ', cmd = 'git branch --sort=-committerdate --no-color', actions = { ['default'] = function(selected) local base = selected[1]:gsub('^[%s%*%+]+', ''):match('([^%s]+)') require('fzf-lua').git_branches({ prompt = 'Compare branch> ', cmd = 'git branch --sort=-committerdate --no-color', actions = { ['default'] = function(selected2) local compare = selected2[1]:gsub('^[%s%*%+]+', ''):match('([^%s]+)') vim.cmd('DiffviewOpen ' .. base .. '...' .. compare) end } }) end } })<CR>";
            desc = "Diff compare branches";
          }
          {
            key = "<leader>gdm";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').git_branches({ prompt = 'Compare to main> ', cmd = 'git branch --sort=-committerdate --no-color', actions = { ['default'] = function(selected) local branch = selected[1]:gsub('^[%s%*%+]+', ''):match('([^%s]+)') vim.cmd('DiffviewOpen main...' .. branch) end } })<CR>";
            desc = "Diff branch against main";
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
      };
    };
  };
}
