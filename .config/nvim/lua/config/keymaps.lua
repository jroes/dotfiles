-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <leader>n in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<leader>n', '<cmd>nohlsearch<CR>', { desc = '[N]o search highlight' })

-- Makes saving files easier
vim.keymap.set('n', '<leader>u', ':update<cr>', { desc = '[U]pdate file' })

-- Use jk to escape insert mode
vim.keymap.set('i', 'jk', '<Esc>')

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- vim: ts=2 sts=2 sw=2 et
