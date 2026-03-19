{pkgs, ...}: {
  programs.nvf.settings.vim = {
    extraPlugins.reviewthem-nvim = {
      package = pkgs.vimUtils.buildVimPlugin {
        pname = "reviewthem-nvim";
        version = "2025-03-19";
        src = pkgs.fetchFromGitHub {
          owner = "KEY60228";
          repo = "reviewthem.nvim";
          rev = "main";
          hash = "sha256-ILv64yT4BcnYcnA9miilyEARBpDxFIWXt41LZMCB1Qk=";
        };
      };
      setup = ''
        require("reviewthem").setup({
          diff_tool = "diffview",
          submit_format = "json",
          submit_destination = "clipboard",
          keymaps = {
            start_review = "<leader>rs",
            add_comment = "<leader>rc",
            submit_review = "<leader>rS",
            abort_review = "<leader>ra",
            show_comments = "<leader>rl",
            toggle_reviewed = "<leader>rm",
            show_status = "<leader>rr",
          },
        })
      '';
    };
  };
}
