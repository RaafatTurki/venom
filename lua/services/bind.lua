--- defines vanilla and (a much as possible) plugin keybinds
-- @module bind
local M = {}

M.bind_leader = U.Service():new(function()
  M.key({'<Space>', '<Nop>', mode = ''})
  vim.g.mapleader = ' '
end)

M.keys = {}

-- a keymap object is {lhs, rhs, opts = {}, mode = string}
M.key = U.Service():new(function(keymap)
  keymap.opts = keymap.opts or { noremap = true, silent = true }
  keymap.mode = keymap.mode and vim.split(keymap.mode, ' ') or 'n'

  vim.keymap.set(keymap.mode, keymap[1], keymap[2], keymap.opts)
  table.insert(M.keys, keymap)
end)

M.setup = U.Service():new(function()
  -- DISABLES
  -- ctrl-x submode, c-p and c-n
  M.key {'<C-x>',            '<Nop>', mode = 'i'}
  -- disable arrow keys
  -- M.key {'<Down>',           '<Nop>', mode = 'n v i'}
  -- M.key {'<Up>',             '<Nop>', mode = 'n v i'}
  -- M.key {'<Left>',           '<Nop>', mode = 'n v i'}
  -- M.key {'<Right>',          '<Nop>', mode = 'n v i'}
  -- home and end
  -- M.key {'<Home>',           '<Nop>', mode = 'n v i'}
  -- M.key {'<End>',            '<Nop>', mode = 'n v i'}

  -- CURSED
  --- hjkl to jkil
  -- M.key {'i',                'k', mode = 'n v i'}
  -- M.key {'k',                'j', mode = 'n v i'}
  -- M.key {'j',                'h', mode = 'n v i'}
  -- M.key {'h',                '<Nop>', mode = 'n v i'}


  -- BASE
  -- write, undo, quit
  Events.write:sub(vim.cmd.write)
  Events.write:sub(vim.cmd.stopinsert)
  M.key {'<C-s>',             function() Events.write() end, mode = 'n v i'}
  M.key {'<C-z>',             function() vim.cmd.undo() end, mode = 'n v i'}
  M.key {'<C-c>',             function() vim.cmd.quit() end, mode = 'n v i'}
  -- M.key {'<A-c>',             function() vim.cmd.bdelete() end, mode = 'n v i'}
  M.key {'<C-q>',             function() vim.cmd.quitall() end, mode = 'n v i'}
  -- page shift up/down, select all
  M.key {'<C-Up>',            '<C-y>k'}
  M.key {'<C-Down>',          '<C-e>j'}
  -- M.key {'<C-a>',            ':%'}
  -- quick fix list
  M.key {'<S-Up>',          '<CMD>cprevious<CR>'}
  M.key {'<S-Down>',            '<CMD>cnext<CR>'}
  -- filter
  M.key {'==',                '==_'}
  M.key {'=',                 '=gv_', mode = 'v'}
  -- switch between last 2 windows
  M.key {'<A-Tab>',           '<C-w>p'}
  -- make x delete without copying
  -- M.key {'x',                '"_x', mode = 'v n'}
  M.key {'X',                 '"_x', mode = 'v n'}
  -- preserve cursor position after a yank
  M.key {'y',                 "ygv<ESC>", mode = 'v'}
  -- make Y copy to end of line in normal mode
  M.key {'Y',                 'y$'}
  -- copy and retain visual selection in visual mode
  M.key {'Y',                 'ygv', mode = 'v'}
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
  -- terminal smart escape
  M.key {'<Esc>',             "v:lua.TermSmartEsc(b:terminal_job_pid, '"..'<Esc>'.."')", mode = 't', opts = { noremap = true, expr = true } }
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
M.setup_plugins = U.Service():new(function()
  -- open uri under cursor
  M.key {'gx',                OpenURIUnderCursor}
  -- cycle theme
  -- M.key {'<leader>t',         Themes.theme_cycle}


  -- PLUGINS
  M.key {'<A-c>',             function() require 'mini.bufremove'.delete() end, mode = 'n v i'}
  -- packer sync
  M.key {'<leader>p',         function() PluginManager.sync() end}
  -- toggle term
  M.key {[[<C-\>]],           '<CMD>ToggleTerm<CR>', mode = 'n'}
  M.key {[[<C-\>]],           [[<C-\><C-n><CMD>ToggleTerm<CR>]], mode = 't'}
  -- nvim tree
  M.key {'<C-e>',             '<CMD>NvimTreeToggle<CR>', mode = 'i n'}
  -- M.key {'<C-e>',             '<CMD>Neotree toggle<CR>', mode = 'i n'}
  -- fold-cycle
  M.key {'za',                function() require 'fold-cycle'.toggle_all() Events.fold_update() end}
  M.key {'z<Right>',          function() require 'fold-cycle'.open() Events.fold_update() end}
  M.key {'z<Left>',           function() require 'fold-cycle'.close() Events.fold_update() end}
  M.key {'z<Down>',           function() require 'fold-cycle'.open_all() Events.fold_update() end}
  M.key {'z<Up>',             function() require 'fold-cycle'.close_all() Events.fold_update() end}
  -- fold-preview
  M.key {'zq',                function() require 'fold-preview'.toggle_preview() end}
  -- gitsigns
  M.key {'gr',                '<CMD>Gitsigns reset_hunk<CR>'}
  M.key {'gr',                function()
    require 'gitsigns'.reset_hunk({ vim.fn.line('v'), vim.fn.getpos('.')[2] })
    -- TODO: find a better way to switch back to normal mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 't', false)
  end, mode = 'v'}
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
  -- mini.move
  M.key {'<Tab>',             function() require 'mini.move'.move_line('right') end, mode = 'n' }
  M.key {'<S-Tab>',           function() require 'mini.move'.move_line('left') end, mode = 'n' }
  M.key {'<Tab>',             function() require 'mini.move'.move_selection('right') end, mode = 'x' }
  M.key {'<S-Tab>',           function() require 'mini.move'.move_selection('left') end, mode = 'x' }
  M.key {'<A-Down>',          function() require 'mini.move'.move_line('down') end, mode = 'n' }
  M.key {'<A-Up>',            function() require 'mini.move'.move_line('up') end, mode = 'n' }
  M.key {'<A-Down>',          function() require 'mini.move'.move_selection('down') end, mode = 'x' }
  M.key {'<A-Up>',            function() require 'mini.move'.move_selection('up') end, mode = 'x' }
  -- lsp installer
  M.key {'<leader>l',         '<CMD>Mason<CR>'}
  -- lsp
  M.key {'<leader>r',         '<CMD>LspRename<CR>'}
  M.key {'<leader>R',         '<CMD>LspReferences<CR>'}
  M.key {'<leader>d',         '<CMD>LspDefinition<CR>'}
  M.key {'<leader>C',         '<CMD>LspCodeAction<CR>'}
  M.key {'<leader>v',         '<CMD>LspHover<CR>'}
  M.key {'<leader>dl',        '<CMD>LspDiagsList<CR>'}
  M.key {'<leader>dv',        '<CMD>LspDiagsHover<CR>'}
  -- telescope
  M.key {'<leader><CR>',      '<CMD>Telescope resume<CR>'}
  M.key {'<leader>f',         '<CMD>Telescope find_files<CR>'}
  M.key {'<leader>g',         '<CMD>Telescope live_grep<CR>'}
  -- neotest
  -- M.key {'<leader>t',         '<CMD>NeotestToggleTree<CR>'}
  -- illuminate
  M.key {'r<Right>',          function() require('illuminate').goto_next_reference() end}
  M.key {'r<Left>',           function() require('illuminate').goto_prev_reference() end}
  -- rest
  M.key {'h<CR>',             '<Plug>RestNvim'}
  -- dial
  -- M.key {'<C-a>',             require 'dial.map'.inc_normal, mode = 'n'}
  -- M.key {'<C-x>',             require 'dial.map'.dec_normal, mode = 'n'}
  -- M.key {'<C-a>',             require 'dial.map'.inc_visual, mode = 'v'}
  -- M.key {'<C-x>',             require 'dial.map'.dec_visual, mode = 'v'}
  -- M.key {'g<C-a>',            require 'dial.map'.inc_gvisual, mode = 'v'}
  -- M.key {'g<C-x>',            require 'dial.map'.dec_gvisual, mode = 'v'}

  -- M.key {'<C-Right>', '<Plug>luasnip-next-choice'}
  -- imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
  -- smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'

end)

return M
