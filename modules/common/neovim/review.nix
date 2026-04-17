{pkgs, ...}: {
  programs.nvf.settings.vim = {
    extraPlugins.review-comments = {
      package = pkgs.vimUtils.buildVimPlugin {
        pname = "review-comments";
        version = "0.1.0";
        src = ./plugins/review-comments;
      };
      setup = "require('review-comments').setup()";
    };
  };
}
