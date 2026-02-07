{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ripgrep
    fd
    fzf
  ];

  programs.neovim.defaultEditor = true;

  programs.nvf = {
    enable = true;
    settings = {
      vim.viAlias = false;
      vim.vimAlias = true;
      vim.globals.mapleader = " ";
      vim.options.tabstop = 2;
      vim.options.shiftwidth = 2;
      vim.options.expandtab = true;
      vim.lsp.enable = true;
      vim.telescope.enable = false;
      # Disable cellular automaton
      vim.visuals.cellular-automaton.mappings.makeItRain = null;
      vim.extraPlugins = {
        fzf-lua = {
          package = pkgs.vimPlugins.fzf-lua;
          setup = builtins.readFile ./fzf-lua.lua;
        };
      };
      vim.binds.whichKey.enable = true;
      vim.languages.ts = {
        enable = true;
        lsp.enable = true;
        extraDiagnostics.enable = true;
        format.enable = true;
        format.type = [ "prettier" ];
        treesitter.enable = true;
      };
      vim.languages.nix = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };
      vim.lsp.formatOnSave = true;
      vim.autocomplete.nvim-cmp.enable = true;
      vim.autopairs.nvim-autopairs.enable = true;
      vim.statusline.lualine.enable = true;

      vim.luaConfigRC.terminal-helpers = builtins.readFile ./terminal.lua;
      vim.keymaps = [
        {
          key = "<D-s>";
          mode = [
            "n"
            "i"
          ];
          action = "<cmd>w<CR>";
          desc = "Save file";
        }
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
        {
          key = "<leader>fs";
          mode = "n";
          action = "<cmd>lua require('fzf-lua').live_grep()<CR>";
          desc = "Live grep";
        }
        {
          key = "<leader>fr";
          mode = "n";
          action = "<cmd>lua require('fzf-lua').oldfiles()<CR>";
          desc = "Recent files";
        }
        {
          key = "<leader>fl";
          mode = "n";
          action = "<cmd>lua require('fzf-lua').resume()<CR>";
          desc = "Resume last picker";
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
}
