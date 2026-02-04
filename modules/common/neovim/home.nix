{
  config,
  pkgs,
  bconfig,
  ...
}:
{

  # programs.neovim = {
  #   defaultEditor = true;
  #   enable = true;
  #   vimAlias = true;
  # };
  programs.nvf = {
    enable = true;
    settings = {
      vim.viAlias = false;
      vim.vimAlias = true;
      vim.globals.mapleader = " ";
      vim.lsp.enable = true;
      vim.filetree.nvimTree.enable = true;
    };
  };
}
