{pkgs, ...}: {
  home.packages = with pkgs; [
    vscode-langservers-extracted # Provides vscode-eslint-language-server for nvim-eslint
  ];

  programs.nvf.settings.vim = {
    # ESLint LSP via nvim-eslint (better monorepo support than eslint_d)
    extraPlugins.nvim-eslint = {
      package = pkgs.vimUtils.buildVimPlugin {
        pname = "nvim-eslint";
        version = "2024-03-09";
        src = pkgs.fetchFromGitHub {
          owner = "esmuellert";
          repo = "nvim-eslint";
          rev = "main";
          hash = "sha256-e6uUyMKlY8o+xqcvISpT+TRX6MqOtCK4ShMs4qY1XFY=";
        };
      };
      setup = ''
        require('nvim-eslint').setup({
          bin = 'vscode-eslint-language-server',
          code_actions = {
            enable = true,
            apply_on_save = {
              enable = true,
              types = { "directive", "problem", "suggestion", "layout" },
            },
            disable_rule_comment = { enable = true },
          },
          diagnostics = {
            enable = true,
            run_on = 'type', -- Run on typing, not just save
          },
        })
      '';
    };

    languages.ts = {
      enable = true;
      lsp.enable = true;
      extraDiagnostics.enable = false; # Using nvim-eslint LSP instead of nvim-lint
      format.enable = true;
      format.type = ["prettier"];
      treesitter.enable = true;
      extensions = {
        ts-error-translator.enable = true;
      };
    };

    luaConfigRC.eslint-fix-all = ''
      function eslint_fix_all_sync()
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'eslint' })
        if #clients == 0 then return end

        clients[1]:request_sync('workspace/executeCommand', {
          command = 'eslint.applyAllFixes',
          arguments = {
            {
              uri = vim.uri_from_bufnr(bufnr),
              version = vim.lsp.util.buf_versions[bufnr],
            },
          },
        }, 3000, bufnr)
      end
    '';
  };
}
