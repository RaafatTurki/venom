local U = require 'utils'

local M = {}

-- a keymap object is {lhs, rhs, opts = {}, mode = string}
bind = service(function(keybind)
  keybind.opts = vim.tbl_deep_extend('force', keybind.opts or {}, { noremap = true, silent = true })
  ---@diagnostic disable-next-line: param-type-mismatch
  keybind.mode = keybind.mode and vim.split(keybind.mode, ' ', {}) or 'n'

  vim.keymap.set(keybind.mode, keybind[1], keybind[2], keybind.opts)
end)

M.setup = service(function()
  -- LEADER KEY
  bind({'<Space>', '<Nop>', mode = ''})
  vim.g.mapleader = ' '

  -- DISABLES
  -- ctrl-x submode, c-p and c-n
  bind {'<C-x>',            '<Nop>', mode = 'i'}
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
  events.write:sub(vim.cmd.write)
  events.write:sub(vim.cmd.stopinsert)
  bind {'<C-s>',             function() events.write() end, mode = 'n x i'}
  bind {'<C-z>',             function() vim.cmd.undo() end, mode = 'n x i'}
  bind {'<C-c>',             function() vim.cmd.quit() end, mode = 'n x i'}
  -- M.key {'<A-c>',             function() vim.cmd.bdelete() end, mode = 'n v i'}
  bind {'<C-q>',             function() vim.cmd.quitall() end, mode = 'n x i'}
  -- page shift up/down, select all
  bind {'<C-Up>',            '<C-y>k'}
  bind {'<C-Down>',          '<C-e>j'}
  -- spell
  bind {'<leader>s',         Lang.toggle_spell}
  -- M.key {'<C-a>',            ':%'}
  -- quick fix list
  bind {'<S-Up>',            '<CMD>cprevious<CR>'}
  bind {'<S-Down>',          '<CMD>cnext<CR>'}
  -- filter
  bind {'==',                '==_'}
  bind {'=',                 '=gv_', mode = 'x'}
  -- switch between last 2 windows
  bind {'<A-Tab>',           '<C-w>p'}
  -- make x delete without copying
  -- M.key {'x',                '"_x', mode = 'x n'}
  bind {'X',                 '"_x', mode = 'x n'}
  -- preserve cursor position after a yank
  bind {'y',                 "ygv<ESC>", mode = 'x'}
  -- make Y copy to end of line in normal mode
  bind {'Y',                 'y$'}
  -- copy and retain visual selection in visual mode
  bind {'Y',                 'ygv', mode = 'x'}
  -- go to end after a join
  bind {'J',                 'J$'}
  -- split (opposite of J)
  bind {'S',                 'T hr<CR>k$'}
  -- swap # and *
  bind {'*',            '#'}
  bind {'#',            '*'}
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
  events.clear:sub [[noh]]
  events.clear:sub(U.clear_prompt)
  bind {'<C-l>',             function() events.clear() end}
  bind {'<C-l>',             '<ESC>', mode = 'i'}
  -- undo breakpoints
  local undo_break_points = {',', '.', '!', '?', '-'}
  for _, break_point in pairs(undo_break_points) do
    bind {break_point,       break_point..'<C-g>u', mode = 'i'}
  end
  -- goto and display to nex/prev lsp diagnositc
  bind {'d<Left>',           function() vim.diagnostic.goto_prev({ float = false }) end}
  bind {'d<Right>',          function() vim.diagnostic.goto_next({ float = false }) end}
  -- tabs
  bind {'<C-t>',             vim.cmd.tabnew}
  bind {'<S-Right>',         vim.cmd.tabnext}
  bind {'<S-Left>',          vim.cmd.tabprevious}
  -- buffers
  bind {'<A-Left>',          function() Buffers.buflist:set_active_buf({ rel_index = 1 }) end}
  bind {'<A-Right>',         function() Buffers.buflist:set_active_buf({ rel_index = -1 }) end}
  for i, label in ipairs(Buffers.buflist.labels) do
    bind {'<A-'..label..'>',      function() Buffers.buflist:set_active_buf({ label = label }) end}
  end
  bind {'<A-S-Left>',        function() Buffers.buflist:shift_active_buf(-1) end}
  bind {'<A-S-Right>',       function() Buffers.buflist:shift_active_buf(1) end}
  -- guifont ()
  bind {'<C-)>',             function() U.change_guifont_size(10, 8, 30) end}
  bind {'<C-_>',             function() U.change_guifont_size(-1, 8, 30, true) end}
  bind {'<C-+>',             function() U.change_guifont_size(1, 8, 30, true) end}

  -- MOTIONS
  bind {'aa',                ':<c-u>normal! ggVG<CR>', mode = 'o'}

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
M.setup_plugins = service(function()
  -- Builtins
  -- open uri under cursor
  bind {'gx',                OpenURIUnderCursor }
  -- plugin manager sync
  bind {'<leader>p',         PluginManager.sync }
  -- lsp
  bind {'<leader>D',         Lsp.toggle_diags }
  bind {'<leader>r',         Lsp.rename }
  bind {'<leader>R',         Lsp.references }
  bind {'<leader>d',         Lsp.definition }
  bind {'<leader>C',         Lsp.code_action }
  bind {'<leader>v',         Lsp.hover }
  bind {'<leader>x',         Lsp.diags_hover }
  bind {'<leader>X',         Lsp.diags_list }
  -- terminal smart escape
  bind {'<Esc>',             TermSmartEsc, mode = 't', opts = { expr = true }}

  -- PLUGINS
  if feat_list:has(feat.CONF, 'nvim-tree.lua') then
    bind {'<C-e>',             '<CMD>NvimTreeToggle<CR>', mode = 'i n'}
  end

  if feat_list:has(feat.CONF, 'neo-tree.nvim') then
    bind {'<C-e>',             '<CMD>Neotree toggle<CR>', mode = 'i n'}
  end

  if feat_list:has(feat.CONF, 'sfm.nvim') then
    bind {'<C-e>',             '<CMD>SFMToggle<CR>', mode = 'i n'}
  end

  if feat_list:has(feat.CONF, 'fold-cycle.nvim') then
    bind {'za',                function() require 'fold-cycle'.toggle_all() events.fold_update() end }
    bind {'z<Right>',          function() require 'fold-cycle'.open() events.fold_update() end }
    bind {'z<Left>',           function() require 'fold-cycle'.close() events.fold_update() end }
    bind {'z<Down>',           function() require 'fold-cycle'.open_all() events.fold_update() end }
    bind {'z<Up>',             function() require 'fold-cycle'.close_all() events.fold_update() end }
  end

  if feat_list:has(feat.CONF, 'fold-preview.nvim') then
    bind {'zq',                function() require 'fold-preview'.toggle_preview() end}
  end

  if feat_list:has(feat.CONF, 'gitsigns.nvim') then
    bind {'gr',                '<CMD>Gitsigns reset_hunk<CR>'}
    bind {'gr',                function()
      require 'gitsigns'.reset_hunk({ vim.fn.line('v'), vim.fn.getpos('.')[2] })
      -- TODO: find a better way to switch back to normal mode
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 't', false)
    end, mode = 'x'}
    bind {'gp',                '<CMD>Gitsigns preview_hunk<CR>'}
    bind {'gb',                '<CMD>Gitsigns blame_line<CR>'}
    bind {'gd',                '<CMD>Gitsigns diffthis<CR>'}
    bind {'gs',                '<CMD>Gitsigns stage_hunk<CR>'}
    bind {'gs',                function()
      require 'gitsigns'.stage_hunk({ vim.fn.line('v'), vim.fn.getpos('.')[2] })
      -- TODO: find a better way to switch back to normal mode
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 't', false)
    end, mode = 'v' }
    bind {'gu',                '<CMD>Gitsigns undo_stage_hunk<CR>'}
    bind {'g<Left>',           '<CMD>Gitsigns prev_hunk<CR>zz'}
    bind {'g<Right>',          '<CMD>Gitsigns next_hunk<CR>zz'}
  end

  if feat_list:has(feat.CONF, 'mini.nvim.bufremove') then
    bind {'<A-c>',             function() require 'mini.bufremove'.delete() end, mode = 'n x i'}
  end
  
  if feat_list:has(feat.CONF, 'mini.nvim.move') then
    bind {'<Tab>',             function() require 'mini.move'.move_line('right') end, mode = 'n' }
    bind {'<S-Tab>',           function() require 'mini.move'.move_line('left') end, mode = 'n' }
    bind {'<Tab>',             function() require 'mini.move'.move_selection('right') end, mode = 'x' }
    bind {'<S-Tab>',           function() require 'mini.move'.move_selection('left') end, mode = 'x' }
    bind {'<A-Down>',          function() require 'mini.move'.move_line('down') end, mode = 'n' }
    bind {'<A-Up>',            function() require 'mini.move'.move_line('up') end, mode = 'n' }
    bind {'<A-Down>',          function() require 'mini.move'.move_selection('down') end, mode = 'x' }
    bind {'<A-Up>',            function() require 'mini.move'.move_selection('up') end, mode = 'x' }
  end
 
  if feat_list:has(feat.CONF, 'mini.nvim.files') then
    bind {'<C-e>',             function() MiniFiles.open() end, mode = 'i n'}
  end

  if feat_list:has(feat.PLUGIN, 'mason.nvim') then
    bind {'<leader>l',         '<CMD>Mason<CR>'}
  end

  if feat_list:has(feat.CONF, 'telescope.nvim') then
    bind {'<leader><CR>',      '<CMD>Telescope resume<CR>'}
    bind {'<leader>f',         '<CMD>Telescope find_files<CR>'}
    bind {'<leader>g',         '<CMD>Telescope live_grep<CR>'}
  end

  -- neotest
  -- M.key {'<leader>t',         '<CMD>NeotestToggleTree<CR>'}

  if feat_list:has(feat.CONF, 'vim-illuminate') then
    bind {'r<Right>',          function() require('illuminate').goto_next_reference() end}
    bind {'r<Left>',           function() require('illuminate').goto_prev_reference() end}
  end
  
  if feat_list:has(feat.CONF, 'rest.nvim') then
    bind {'h<CR>',             '<Plug>RestNvim'}
  end

  -- M.key {'<C-Right>', '<Plug>luasnip-next-choice'}
  -- imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
  -- smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'

end)

return M
