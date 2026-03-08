{pkgs, ...}: {
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

        lsp.enable = true;
        fzf-lua = {
          enable = true;
          setupOpts = {
            keymap = {
              fzf = {
                "ctrl-q" = "select-all+accept";
                "ctrl-a" = "select-all";
              };
            };
          };
        };

        binds.whichKey.enable = true;

        autocomplete.nvim-cmp.enable = true;
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
          ts = {
            enable = true;
            lsp.enable = true;
            extraDiagnostics.enable = true;
            format.enable = true;
            format.type = ["prettier"];
            treesitter.enable = true;
          };

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
          };
        };

        utility.diffview-nvim = {
          enable = true;
          setupOpts = {
            keymaps = {
              view = [
                ["n" "q" "<Cmd>DiffviewClose<CR>" {desc = "Close diffview";}]
              ];
              file_panel = [
                ["n" "q" "<Cmd>DiffviewClose<CR>" {desc = "Close diffview";}]
              ];
            };
          };
        };
        filetree.neo-tree.enable = true;

        luaConfigRC.terminal-helpers = builtins.readFile ./terminal.lua;

        keymaps = [
          {
            key = "<C-s>";
            mode = [
              "n"
              "i"
            ];
            action = "<cmd>w<CR>";
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

          # Git
          {
            key = "<leader>g";
            mode = "n";
            action = "<cmd>Neogit<CR>";
            desc = "Open git";
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
