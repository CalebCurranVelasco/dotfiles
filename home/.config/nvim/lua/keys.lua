-- select all
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })
-- typing kj in insert or visual mode exits to normal mode, same as Esc
vim.keymap.set({ 'i', 'v' }, 'kj', '<Esc>', { desc = 'Exit insert/visual mode' })
-- pasting over a selection no longer clobbers your clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])
