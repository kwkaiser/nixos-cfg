{pkgs, ...}: {
  home.packages = with pkgs; [
    ripgrep
    fd
    fzf
  ];

  programs.neovim = {
    defaultEditor = true;
    vimAlias = true;
  };

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        vimAlias = true;
        globals.mapleader = " ";
        clipboard.enable = true;
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
        statusline.lualine.enable = true;

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
            key = "<leader>lq";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').diagnostics_workspace()<CR>";
            desc = "Dump LSP diagnostics into quickfix";
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
