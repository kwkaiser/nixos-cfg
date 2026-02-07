require('fzf-lua').setup({
  winopts = {
    height = 0.85,
    width = 0.80,
    preview = {
      layout = 'flex',
      flip_columns = 120,
    },
  },
  keymap = {
    builtin = {
      ['<C-d>'] = 'preview-page-down',
      ['<C-u>'] = 'preview-page-up',
    },
    fzf = {
      ['ctrl-j'] = 'down',
      ['ctrl-k'] = 'up',
      ['ctrl-q'] = 'select-all+accept',
    },
  },
  buffers = {
    actions = {
      ['ctrl-d'] = { require('fzf-lua.actions').buf_del, require('fzf-lua.actions').resume },
    },
  },
  files = {
    fd_opts = '--type f --hidden --follow --exclude .git',
  },
  grep = {
    rg_opts = '--column --line-number --no-heading --color=always --smart-case --hidden --glob "!.git"',
  },
})
