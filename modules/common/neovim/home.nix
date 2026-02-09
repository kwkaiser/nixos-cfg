{pkgs, ...}: {
  home.packages = with pkgs; [
    ripgrep
    fd
    fzf
  ];

  programs.neovim.defaultEditor = true;

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        vimAlias = true;
        globals.mapleader = " ";
        options = {
          tabstop = 2;
          shiftwidth = 2;
          expandtab = true;
        };

        lsp.enable = true;
        fzf-lua.enable = true;

        binds.whichKey = {
          enable = true;
          register = {
            "<leader>fg" = "Git browse";
          };
        };

        autocomplete.nvim-cmp.enable = true;
        autopairs.nvim-autopairs.enable = true;
        statusline.lualine.enable = true;

        lsp.formatOnSave = true;

        languages = {
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
        };

        luaConfigRC.terminal-helpers = builtins.readFile ./terminal.lua;

        keymaps = [
          {
            key = "<D-s>";
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
            key = "<leader>fgs";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').git_status()<CR>";
            desc = "Git status";
          }

          {
            key = "<leader>fgc";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').git_commits()<CR>";
            desc = "Git commits";
          }

          {
            key = "<leader>fgb";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').git_branches()<CR>";
            desc = "Git branches";
          }

          {
            key = "<leader>fgl";
            mode = "n";
            action = "<cmd>lua require('fzf-lua').git_blame()<CR>";
            desc = "Git blame";
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
