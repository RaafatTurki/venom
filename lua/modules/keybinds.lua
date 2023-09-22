local U = require 'utils'

local M = {}

-- a keymap object is {lhs, rhs, opts = {}, mode = string}
keybind = service(function(keybind)
  keybind.opts = vim.tbl_deep_extend('force', keybind.opts or {}, { noremap = true, silent = true })
  ---@diagnostic disable-next-line: param-type-mismatch
  keybind.mode = keybind.mode and vim.split(keybind.mode, ' ', {}) or 'n'

  vim.keymap.set(keybind.mode, keybind[1], keybind[2], keybind.opts)
end)

M.setup = service(function()
  -- LEADER KEY
  keybind({'<Space>', '<Nop>', mode = ''})
  vim.g.mapleader = ' '

  -- DISABLES
  -- ctrl-x submode, c-p and c-n
  keybind {'<C-x>',            '<Nop>', mode = 'i'}
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
  keybind {'<C-s>',             function() events.write() end, mode = 'n x i'}
  keybind {'<C-z>',             function() vim.cmd.undo() end, mode = 'n x i'}
  keybind {'<C-c>',             function() vim.cmd.quit() end, mode = 'n x i'}
  -- M.key {'<A-c>',             function() vim.cmd.bdelete() end, mode = 'n v i'}
  keybind {'<C-q>',             function() vim.cmd.quitall() end, mode = 'n x i'}
  -- page shift up/down, select all
  keybind {'<C-Up>',            '<C-y>k'}
  keybind {'<C-Down>',          '<C-e>j'}
  -- spell
  keybind {'<leader>s',         Lang.toggle_spell}
  -- M.key {'<C-a>',            ':%'}
  -- quick fix list
  keybind {'<S-Up>',            '<CMD>cprevious<CR>'}
  keybind {'<S-Down>',          '<CMD>cnext<CR>'}
  -- filter
  keybind {'==',                '==_'}
  keybind {'=',                 '=gv_', mode = 'x'}
  -- switch between last 2 windows
  keybind {'<A-Tab>',           '<C-w>p'}
  -- make x delete without copying
  -- M.key {'x',                '"_x', mode = 'x n'}
  keybind {'X',                 '"_x', mode = 'x n'}
  -- preserve cursor position after a yank
  keybind {'y',                 "ygv<ESC>", mode = 'x'}
  -- make Y copy to end of line in normal mode
  keybind {'Y',                 'y$'}
  -- copy and retain visual selection in visual mode
  keybind {'Y',                 'ygv', mode = 'x'}
  -- go to end after a join
  keybind {'J',                 'J$'}
  -- split (opposite of J)
  keybind {'S',                 'T hr<CR>k$'}
  -- swap # and *
  keybind {'*',            '#'}
  keybind {'#',            '*'}
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
  keybind {'<C-l>',             function() events.clear() end}
  keybind {'<C-l>',             '<ESC>', mode = 'i'}
  -- undo breakpoints
  local undo_break_points = {',', '.', '!', '?', '-'}
  for _, break_point in pairs(undo_break_points) do
    keybind {break_point,       break_point..'<C-g>u', mode = 'i'}
  end
  -- goto and display to nex/prev lsp diagnositc
  keybind {'d<Left>',           function() vim.diagnostic.goto_prev({ float = false }) end}
  keybind {'d<Right>',          function() vim.diagnostic.goto_next({ float = false }) end}
  -- tabs
  keybind {'<C-t>',             vim.cmd.tabnew}
  keybind {'<S-Right>',         vim.cmd.tabnext}
  keybind {'<S-Left>',          vim.cmd.tabprevious}
  -- buffers
  keybind {'<A-Left>',          function() Buffers.buflist:set_active_buf({ rel_index = 1 }) end}
  keybind {'<A-Right>',         function() Buffers.buflist:set_active_buf({ rel_index = -1 }) end}
  for i, label in ipairs(Buffers.buflist.labels) do
    keybind {'<A-'..label..'>',      function() Buffers.buflist:set_active_buf({ label = label }) end}
  end
  keybind {'<A-S-Left>',        function() Buffers.buflist:shift_buf(0, -1) end}
  keybind {'<A-S-Right>',       function() Buffers.buflist:shift_buf(0, 1) end}
  -- guifont ()
  keybind {'<C-)>',             function() U.change_guifont_size(10, 8, 30) end}
  keybind {'<C-_>',             function() U.change_guifont_size(-1, 8, 30, true) end}
  keybind {'<C-+>',             function() U.change_guifont_size(1, 8, 30, true) end}

  -- MOTIONS
  keybind {'aa',                ':<c-u>normal! ggVG<CR>', mode = 'o'}

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
  keybind {'gx',                OpenURIUnderCursor }
  -- plugin manager sync
  keybind {'<leader>p',         PluginManager.sync }
  -- lsp
  keybind {'<leader>D',         Lsp.toggle_diags }
  keybind {'<leader>r',         Lsp.rename }
  keybind {'<leader>R',         Lsp.references }
  keybind {'<leader>d',         Lsp.definition }
  keybind {'<leader>C',         Lsp.code_action }
  keybind {'<leader>v',         Lsp.hover }
  keybind {'<leader>x',         Lsp.diags_hover }
  keybind {'<leader>X',         Lsp.diags_list }
  -- terminal smart escape
  keybind {'<Esc>',             TermSmartEsc, mode = 't', opts = { expr = true }}

  -- PLUGINS
  if feat_list:has(feat.CONF, 'nvim-tree.lua') then
    keybind {'<C-e>',             '<CMD>NvimTreeToggle<CR>', mode = 'i n'}
  end

  if feat_list:has(feat.CONF, 'neo-tree.nvim') then
    keybind {'<C-e>',             '<CMD>Neotree toggle<CR>', mode = 'i n'}
  end

  if feat_list:has(feat.CONF, 'sfm.nvim') then
    keybind {'<C-e>',             '<CMD>SFMToggle<CR>', mode = 'i n'}
  end

  if feat_list:has(feat.CONF, 'fold-cycle.nvim') then
    keybind {'za',                function() require 'fold-cycle'.toggle_all() events.fold_update() end }
    keybind {'z<Right>',          function() require 'fold-cycle'.open() events.fold_update() end }
    keybind {'z<Left>',           function() require 'fold-cycle'.close() events.fold_update() end }
    keybind {'z<Down>',           function() require 'fold-cycle'.open_all() events.fold_update() end }
    keybind {'z<Up>',             function() require 'fold-cycle'.close_all() events.fold_update() end }
  end

  if feat_list:has(feat.CONF, 'nvim-ufo') then
    keybind {'zR',                function() require 'ufo'.openAllFolds() events.fold_update() end }
    keybind {'zM',                function() require 'ufo'.closeAllFolds() events.fold_update() end }
    keybind {'zq',                function() require 'ufo'.peekFoldedLinesUnderCursor() end}
  end

  if feat_list:has(feat.CONF, 'fold-preview.nvim') then
    keybind {'zq',                function() require 'fold-preview'.toggle_preview() end}
  end

  if feat_list:has(feat.CONF, 'gitsigns.nvim') then
    keybind {'gr',                '<CMD>Gitsigns reset_hunk<CR>'}
    keybind {'gr',                function()
      require 'gitsigns'.reset_hunk({ vim.fn.line('v'), vim.fn.getpos('.')[2] })
      -- TODO: find a better way to switch back to normal mode
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 't', false)
    end, mode = 'x'}
    keybind {'gp',                '<CMD>Gitsigns preview_hunk<CR>'}
    keybind {'gb',                '<CMD>Gitsigns blame_line<CR>'}
    keybind {'gd',                '<CMD>Gitsigns diffthis<CR>'}
    keybind {'gs',                '<CMD>Gitsigns stage_hunk<CR>'}
    keybind {'gs',                function()
      require 'gitsigns'.stage_hunk({ vim.fn.line('v'), vim.fn.getpos('.')[2] })
      -- TODO: find a better way to switch back to normal mode
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 't', false)
    end, mode = 'v' }
    keybind {'gu',                '<CMD>Gitsigns undo_stage_hunk<CR>'}
    keybind {'g<Left>',           '<CMD>Gitsigns prev_hunk<CR>zz'}
    keybind {'g<Right>',          '<CMD>Gitsigns next_hunk<CR>zz'}
  end

  if feat_list:has(feat.CONF, 'mini.nvim.bufremove') then
    keybind {'<A-c>',             function() require 'mini.bufremove'.delete() end, mode = 'n x i'}
  end
  
  if feat_list:has(feat.CONF, 'mini.nvim.move') then
    keybind {'<Tab>',             function() require 'mini.move'.move_line('right') end, mode = 'n' }
    keybind {'<S-Tab>',           function() require 'mini.move'.move_line('left') end, mode = 'n' }
    keybind {'<Tab>',             function() require 'mini.move'.move_selection('right') end, mode = 'x' }
    keybind {'<S-Tab>',           function() require 'mini.move'.move_selection('left') end, mode = 'x' }
    keybind {'<A-Down>',          function() require 'mini.move'.move_line('down') end, mode = 'n' }
    keybind {'<A-Up>',            function() require 'mini.move'.move_line('up') end, mode = 'n' }
    keybind {'<A-Down>',          function() require 'mini.move'.move_selection('down') end, mode = 'x' }
    keybind {'<A-Up>',            function() require 'mini.move'.move_selection('up') end, mode = 'x' }
  end
 
  if feat_list:has(feat.CONF, 'mini.nvim.files') then
    keybind {'<C-e>',             function() MiniFiles.open() end, mode = 'i n'}
  end

  if feat_list:has(feat.PLUGIN, 'mason.nvim') then
    keybind {'<leader>l',         '<CMD>Mason<CR>'}
  end

  if feat_list:has(feat.PLUGIN, 'nvim-dap') then
    keybind {'<leader>b',         '<CMD>DapToggleBreakpoint<CR>'}
  end

  if feat_list:has(feat.CONF, 'telescope.nvim') then
    keybind {'<leader><CR>',      '<CMD>Telescope resume<CR>'}
    keybind {'<leader>f',         '<CMD>Telescope find_files<CR>'}
    keybind {'<leader>g',         '<CMD>Telescope live_grep<CR>'}
  end

  if feat_list:has(feat.CONF, 'view.nvim') then
    keybind {'<A-v>',      require 'view'.next}
  end

  -- neotest
  -- M.key {'<leader>t',         '<CMD>NeotestToggleTree<CR>'}

  if feat_list:has(feat.CONF, 'vim-illuminate') then
    keybind {'r<Right>',          function() require('illuminate').goto_next_reference() end}
    keybind {'r<Left>',           function() require('illuminate').goto_prev_reference() end}
  end
  
  if feat_list:has(feat.CONF, 'rest.nvim') then
    keybind {'<leader>',             '<Plug>RestNvim'}
  end

  -- M.key {'<C-Right>', '<Plug>luasnip-next-choice'}
  -- imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
  -- smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'

end)

return M
