{pkgs, lib, isDarwin, ...}: {
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

    languages.typescript = {
      enable = true;
      lsp.enable = true;
      lsp.servers = ["typescript-go"];
      extraDiagnostics.enable = false; # Using nvim-eslint LSP instead of nvim-lint
      format.enable = true;
      treesitter.enable = true;
    };

    luaConfigRC.tsgo-bundled-glob-workaround = lib.mkIf isDarwin ''
      local _orig_register_cap = vim.lsp.handlers['client/registerCapability']
      vim.lsp.handlers['client/registerCapability'] = function(err, result, ctx, config)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client and client.name == 'typescript-go' and result and result.registrations then
          for _, reg in ipairs(result.registrations) do
            if reg.method == 'workspace/didChangeWatchedFiles'
              and reg.registerOptions
              and reg.registerOptions.watchers
            then
              reg.registerOptions.watchers = vim.tbl_filter(function(w)
                local pat = type(w.globPattern) == 'string' and w.globPattern
                  or (type(w.globPattern) == 'table' and w.globPattern.pattern or "")
                return not vim.startswith(pat, 'bundled://')
              end, reg.registerOptions.watchers)
            end
          end
        end
        return _orig_register_cap(err, result, ctx, config)
      end
    '';

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
