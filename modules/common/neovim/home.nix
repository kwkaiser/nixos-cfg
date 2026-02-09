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

        binds.whichKey.enable = true;

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

        utility.diffview-nvim.enable = true;
        filetree.neo-tree.enable = true;

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
            key = "<leader>g";
            mode = "n";
            action = "<cmd>:Neogit<CR>";
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
