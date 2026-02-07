{pkgs, ...}: {
  home.packages = with pkgs; [
    ripgrep
    fd
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
      vim.telescope.enable = true;
      vim.telescope.mappings = {
        # Disable git extensions
        gitBranches = null;
        gitCommits = null;
        gitFiles = null;
        gitStash = null;
        gitStatus = null;
        gitBufferCommits = null;
        # Disable open
        open = null;
        # Disable lsp extensions
        lspDocumentSymbols = null;
        lspReferences = null;
        lspWorkspaceSymbols = null;
        lspDefinitions = null;
        lspTypeDefinitions = null;
        lspImplementations = null;
        # Disable resume
        resume = null;
        # Disable treesitter
        treesitter = null;
        # Disable grep
        liveGrep = null;
        # Disable help tags
        helpTags = null;
        # Disable diagnostics
        diagnostics = null;
      };
      # Disable cellular automaton
      vim.visuals.cellular-automaton.mappings.makeItRain = null;
      vim.extraPlugins = {
        telescope-file-browser = {
          package = pkgs.vimPlugins.telescope-file-browser-nvim;
          setup = "require('telescope').load_extension('file_browser')";
        };
      };
      vim.binds.whichKey.enable = true;
      vim.binds.whichKey.register = {
        "<leader>fv" = null;
        "<leader>fvc" = null;
        "<leader>fl" = null;
        "<leader>fm" = null;
      };
      vim.languages.ts = {
        enable = true;
        lsp.enable = true;
        extraDiagnostics.enable = true;
        format.enable = true;
        format.type = ["prettier"];
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

      vim.luaConfigRC.telescope-buffer-delete = builtins.readFile ./telescope.lua;
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
          key = "<leader>fc";
          mode = "n";
          action = "<cmd>Telescope file_browser<CR>";
          desc = "File browser";
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
