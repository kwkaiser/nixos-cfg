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
    # your settings need to go into the settings attribute set
    # most settings are documented in the appendix
    settings = {
      vim.viAlias = false;
      vim.vimAlias = true;
      vim.lsp = {
        enable = true;
      };
    };
  };
}
