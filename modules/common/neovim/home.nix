{
  config,
  pkgs,
  bconfig,
  ...
}:
{

  home.packages = with pkgs; [
    ripgrep
    fd
    # telescope-media-files dependencies
    chafa
    imagemagick
    ffmpegthumbnailer
    poppler-utils
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
      vim.extraPlugins = {
        telescope-file-browser = {
          package = pkgs.vimPlugins.telescope-file-browser-nvim;
          setup = "require('telescope').load_extension('file_browser')";
        };
        telescope-media-files = {
          package = pkgs.vimPlugins.telescope-media-files-nvim;
          setup = "require('telescope').load_extension('media_files')";
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
      vim.language.nix = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };
      vim.lsp.formatOnSave = true;
      vim.autocomplete.nvim-cmp.enable = true;
      vim.autopairs.nvim-autopairs.enable = true;
      vim.statusline.lualine.enable = true;

      vim.luaConfigRC.telescope-buffer-delete = ''
        require('telescope').setup({
          pickers = {
            buffers = {
              mappings = {
                i = {
                  ['<C-d>'] = require('telescope.actions').delete_buffer,
                },
                n = {
                  ['d'] = require('telescope.actions').delete_buffer,
                },
              },
            },
          },
        })
      '';
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
          key = "<leader>fm";
          mode = "n";
          action = "<cmd>Telescope media_files<CR>";
          desc = "Media files";
        }
        {
          key = "<leader>th";
          mode = "n";
          action = "<cmd>lcd %:p:h | split | terminal<CR>";
          desc = "Terminal horizontal";
        }
        {
          key = "<leader>tv";
          mode = "n";
          action = "<cmd>lcd %:p:h | vsplit | terminal<CR>";
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
