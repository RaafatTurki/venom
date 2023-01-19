--- defines vanilla and (a much as possible) plugin keybinds
-- @module bind
local M = {}

M.bind_leader = U.Service(function()
  M.key({'<Space>', '<Nop>', mode = ''})
  vim.g.mapleader = ' '
end)

M.keys = {}

-- a keymap object is {lhs, rhs, opts = {}, mode = string}
M.key = U.Service(function(keymap)
  keymap.opts = vim.tbl_deep_extend('force', keymap.opts or {}, { noremap = true, silent = true })
  keymap.mode = keymap.mode and vim.split(keymap.mode, ' ') or 'n'

  vim.keymap.set(keymap.mode, keymap[1], keymap[2], keymap.opts)
  table.insert(M.keys, keymap)
end)

M.setup = U.Service(function()
  -- DISABLES
  -- ctrl-x submode, c-p and c-n
  M.key {'<C-x>',            '<Nop>', mode = 'i'}
  -- disable arrow keys
  -- M.key {'<Down>',           '<Nop>', mode = 'n x i'}
  -- M.key {'<Up>',             '<Nop>', mode = 'n x i'}
  -- M.key {'<Left>',           '<Nop>', mode = 'n x i'}
  -- M.key {'<Right>',          '<Nop>', mode = 'n x i'}
  -- home and end
  -- M.key {'<Home>',           '<Nop>', mode = 'n x i'}
  -- M.key {'<End>',            '<Nop>', mode = 'n x i'}

  -- CURSED
  --- hjkl to jkil
  -- M.key {'i',                'k', mode = 'n x i'}
  -- M.key {'k',                'j', mode = 'n x i'}
  -- M.key {'j',                'h', mode = 'n x i'}
  -- M.key {'h',                '<Nop>', mode = 'n x i'}


  -- BASE
  -- write, undo, quit
  Events.write:sub(vim.cmd.write)
  Events.write:sub(vim.cmd.stopinsert)
  M.key {'<C-s>',             function() Events.write() end, mode = 'n x i'}
  M.key {'<C-z>',             function() vim.cmd.undo() end, mode = 'n x i'}
  M.key {'<C-c>',             function() vim.cmd.quit() end, mode = 'n x i'}
  -- M.key {'<A-c>',             function() vim.cmd.bdelete() end, mode = 'n v i'}
  M.key {'<C-q>',             function() vim.cmd.quitall() end, mode = 'n x i'}
  -- page shift up/down, select all
  M.key {'<C-Up>',            '<C-y>k'}
  M.key {'<C-Down>',          '<C-e>j'}
  -- M.key {'<C-a>',            ':%'}
  -- quick fix list
  M.key {'<S-Up>',            '<CMD>cprevious<CR>'}
  M.key {'<S-Down>',          '<CMD>cnext<CR>'}
  -- filter
  M.key {'==',                '==_'}
  M.key {'=',                 '=gv_', mode = 'x'}
  -- switch between last 2 windows
  M.key {'<A-Tab>',           '<C-w>p'}
  -- make x delete without copying
  -- M.key {'x',                '"_x', mode = 'x n'}
  M.key {'X',                 '"_x', mode = 'x n'}
  -- preserve cursor position after a yank
  M.key {'y',                 "ygv<ESC>", mode = 'x'}
  -- make Y copy to end of line in normal mode
  M.key {'Y',                 'y$'}
  -- copy and retain visual selection in visual mode
  M.key {'Y',                 'ygv', mode = 'x'}
  -- go to end after a join
  M.key {'J',                 'J$'}
  -- split (opposite of J)
  M.key {'S',                 'T hr<CR>k$'}
  -- open man pages in new tabs
  -- M.key {'K',                 ':tab Man<CR>'}
  -- zt and zb with arrows
  -- M.key {'z<Up>',             'zt'}
  -- M.key {'z<Down>',           'zb'}
  -- center line after n/N
  -- M.key {'n',                'nzzzv'}
  -- M.key {'N',                'Nzzzv'}
  -- refresh action
  -- venom.events.refresh:sub('mkview')
  -- venom.events.refresh:sub('e')
  -- venom.events.refresh:sub('loadview')
  -- M.key {'<F5>',              function() venom.events.refresh() end}
  -- clear action
  -- venom.actions.clear:sub [[let @/ = ""]]
  Events.clear:sub [[noh]]
  Events.clear:sub(U.clear_prompt)
  M.key {'<C-l>',             function() Events.clear() end}
  M.key {'<C-l>',             '<ESC>', mode = 'i'}
  -- undo breakpoints
  local undo_break_points = {',', '.', '!', '?', '-'}
  for _, break_point in pairs(undo_break_points) do
    M.key {break_point,       break_point..'<C-g>u', mode = 'i'}
  end
  -- goto and display to nex/prev lsp diagnositc
  M.key {'d<Left>',           function() vim.diagnostic.goto_prev({ float = false }) end}
  M.key {'d<Right>',          function() vim.diagnostic.goto_next({ float = false }) end}
  -- tabs
  M.key {'<C-t>',             vim.cmd.tabnew}
  M.key {'<S-Right>',         vim.cmd.tabnext}
  M.key {'<S-Left>',          vim.cmd.tabprevious}
  -- buffers
  M.key {'<A-Right>',         vim.cmd.bnext}
  M.key {'<A-Left>',          vim.cmd.bprevious}
  for i, label in ipairs(Buffers.labels) do
    M.key {'<A-'..label..'>',      function() Buffers.buf_switch_by_label(label) end}
  end

  -- MOTIONS
  M.key {'aa',                ':<c-u>normal! ggVG<CR>', mode = 'o'}

  -- TESTING
  -- M.key {'<A-z>',            function() vim.notify("hi friend") end}

  -- old
  -- shifting line
  -- M.key {'<A-Down>',         '<CMD>m .+1<CR>'}
  -- M.key {'<A-Up>',           '<CMD>m .-2<CR>'}
  -- M.key {'<A-Down>',         '<CMD>m .+1<CR><ESC>i', mode = 'i'}
  -- M.key {'<A-Up>',           '<CMD>m .-2<CR><ESC>i', mode = 'i'}
end)

-- TODO load each conditionally depending on registered features
M.setup_plugins = U.Service(function()
  -- Builtins
  -- open uri under cursor
  M.key {'gx',                OpenURIUnderCursor }
  -- plugin manager sync
  M.key {'<leader>p',         PluginManager.sync }
  -- lsp
  M.key {'<leader>r',         Lsp.rename }
  M.key {'<leader>R',         Lsp.references }
  M.key {'<leader>d',         Lsp.definition }
  M.key {'<leader>C',         Lsp.code_action }
  M.key {'<leader>v',         Lsp.hover }
  M.key {'<leader>dl',        Lsp.diags_list }
  M.key {'<leader>dv',        Lsp.diags_hover }
  -- terminal smart escape
  M.key {'<Esc>',             TermSmartEsc, mode = 't', opts = { expr = true }}

  -- PLUGINS
  if Features:has(FT.PLUGIN, 'nvim-toggleterm.lua') then
    M.key {[[<C-\>]],           '<CMD>ToggleTerm<CR>', mode = 'n'}
    M.key {[[<C-\>]],           [[<C-\><C-n><CMD>ToggleTerm<CR>]], mode = 't'}
  end

  if Features:has(FT.PLUGIN, 'nvim-tree.lua') then
    M.key {'<C-e>',             '<CMD>NvimTreeToggle<CR>', mode = 'i n'}
  end

  -- M.key {'<C-e>',             '<CMD>Neotree toggle<CR>', mode = 'i n'}

  if Features:has(FT.PLUGIN, 'fold-cycle.nvim') then
    M.key {'za',                function() require 'fold-cycle'.toggle_all() Events.fold_update() end }
    M.key {'z<Right>',          function() require 'fold-cycle'.open() Events.fold_update() end }
    M.key {'z<Left>',           function() require 'fold-cycle'.close() Events.fold_update() end }
    M.key {'z<Down>',           function() require 'fold-cycle'.open_all() Events.fold_update() end }
    M.key {'z<Up>',             function() require 'fold-cycle'.close_all() Events.fold_update() end }
  end

  if Features:has(FT.PLUGIN, 'fold-preview.nvim') then
    M.key {'zq',                function() require 'fold-preview'.toggle_preview() end}
  end

  if Features:has(FT.PLUGIN, 'gitsigns.nvim') then
    M.key {'gr',                '<CMD>Gitsigns reset_hunk<CR>'}
    M.key {'gr',                function()
      require 'gitsigns'.reset_hunk({ vim.fn.line('v'), vim.fn.getpos('.')[2] })
      -- TODO: find a better way to switch back to normal mode
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 't', false)
    end, mode = 'x'}
    M.key {'gp',                '<CMD>Gitsigns preview_hunk<CR>'}
    M.key {'gb',                '<CMD>Gitsigns blame_line<CR>'}
    M.key {'gd',                '<CMD>Gitsigns diffthis<CR>'}
    M.key {'gs',                '<CMD>Gitsigns stage_hunk<CR>'}
    M.key {'gs',                function()
      require 'gitsigns'.stage_hunk({ vim.fn.line('v'), vim.fn.getpos('.')[2] })
      -- TODO: find a better way to switch back to normal mode
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 't', false)
    end, mode = 'v' }
    M.key {'gu',                '<CMD>Gitsigns undo_stage_hunk<CR>'}
    M.key {'g<Left>',           '<CMD>Gitsigns prev_hunk<CR>zz'}
    M.key {'g<Right>',          '<CMD>Gitsigns next_hunk<CR>zz'}
  end

  if Features:has(FT.PLUGIN, 'mini.nvim') then
    -- mini.bufremove
    M.key {'<A-c>',             function() require 'mini.bufremove'.delete() end, mode = 'n x i'}
    -- mini.move
    M.key {'<Tab>',             function() require 'mini.move'.move_line('right') end, mode = 'n' }
    M.key {'<S-Tab>',           function() require 'mini.move'.move_line('left') end, mode = 'n' }
    M.key {'<Tab>',             function() require 'mini.move'.move_selection('right') end, mode = 'x' }
    M.key {'<S-Tab>',           function() require 'mini.move'.move_selection('left') end, mode = 'x' }
    M.key {'<A-Down>',          function() require 'mini.move'.move_line('down') end, mode = 'n' }
    M.key {'<A-Up>',            function() require 'mini.move'.move_line('up') end, mode = 'n' }
    M.key {'<A-Down>',          function() require 'mini.move'.move_selection('down') end, mode = 'x' }
    M.key {'<A-Up>',            function() require 'mini.move'.move_selection('up') end, mode = 'x' }
  end
  
  if Features:has(FT.PLUGIN, 'mason.nvim') then
    M.key {'<leader>l',         '<CMD>Mason<CR>'}
  end

  if Features:has(FT.PLUGIN, 'telescope.nvim') then
    M.key {'<leader><CR>',      '<CMD>Telescope resume<CR>'}
    M.key {'<leader>f',         '<CMD>Telescope find_files<CR>'}
    M.key {'<leader>g',         '<CMD>Telescope live_grep<CR>'}
  end

  -- neotest
  -- M.key {'<leader>t',         '<CMD>NeotestToggleTree<CR>'}

  if Features:has(FT.PLUGIN, 'vim-illuminate') then
    M.key {'r<Right>',          function() require('illuminate').goto_next_reference() end}
    M.key {'r<Left>',           function() require('illuminate').goto_prev_reference() end}
  end
  
  if Features:has(FT.PLUGIN, 'rest.nvim') then
    M.key {'h<CR>',             '<Plug>RestNvim'}
  end

  -- M.key {'<C-Right>', '<Plug>luasnip-next-choice'}
  -- imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
  -- smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'

end)

return M
