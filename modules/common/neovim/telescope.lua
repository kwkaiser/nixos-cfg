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
